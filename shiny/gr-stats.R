
library(ggplot2)
library(RCurl)
library(reshape2)

# if author url, return author id
ifAuthorURL <- function(gurl) {
  isAuthor <- grepl("author/show/([0-9]*)", gurl)
  if (isAuthor) {
    authorId <- regmatches(gurl, regexpr("author/show/([0-9]*)", gurl))
    authorId <- strsplit(authorId, split = "/")[[1]][3]
    authorId
  } else {
    NA
  }
}

# if user url, return user id
ifUserURL <- function(gurl) {
  isUser <- grepl("user/show/([0-9]*)", gurl)
  if (isUser) {
    userId <- regmatches(gurl, regexpr("user/show/([0-9]*)", gurl))
    userId <- strsplit(userId, split = "/")[[1]][3]
    userId
  } else {
    NA
  }
}

# converts GR url to either userID or author->userID
processURL <- function(gurl) {
  authorId <- ifAuthorURL(gurl)
  userId <- ifUserURL(gurl)
  if (is.na(authorId) & is.na(userId)) {
    NA
  } else {
    if (!is.na(authorId)) {
      gurl <- paste0("http://tools.mediascover.com/gr-auth.php?id=", authorId, collapse="")
      userId <- read.table(url(gurl))$V1
    } else { # isUser
      userId <- regmatches(gurl, regexpr("user/show/([0-9]*)", gurl))
      userId <- strsplit(userId, split = "/")[[1]][3]
    }
    
    # NA if author is not a GR user
    userId
  }
}

# initialize, download data
getData <- function(userId) {
  # gurl <- "http://tools.mediascover.com/gr-stats.php?id=31656053"
  gurl <- "http://tools.mediascover.com/gr-stats.php?id="
  gurl <- paste0(gurl, userId, collapse = "")
  
  data <- 
  tryCatch({
    text <- getURL(gurl, timeout = 999)
    read.csv(textConnection(text), stringsAsFactors = F)
  }, error = function(e) NA )
  data
}

# books read by year / rating
dataBooksPerYear <- function(data) {
  df <- data[!is.na(data$read_at),c("title","read_at","my_rating","num_pages","avg_rating")]
  df <- df[order(df$read_at),]
  df
}
plotBooksPerYear <- function(df) {
  g <- ggplot(df, aes(x = year(read_at), fill=as.factor(my_rating)))
  g <- g + geom_bar()
  g <- g + ggtitle("# of Books Read Per Year")
  g <- g + xlab("Year") + ylab("# of Books")
  g <- g + scale_fill_hue(name="Rating")
  g
}
plotPagesPerYear <- function(df) {
  df[is.na(df$num_pages),"num_pages"] <- 0
  g <- ggplot(df, aes(x = year(read_at), y = num_pages, fill=as.factor(my_rating)))
  g <- g + geom_bar(stat="identity")
  g <- g + ggtitle("# of Pages Read Per Year")
  g <- g + xlab("Year") + ylab("# of Pages")
  g <- g + scale_fill_hue(name="Rating")
  g
}

# books read by year / gender
dataBooksByGender <- function(data) {
  df <- data[!is.na(data$read_at),c("title","read_at","author_name","author_gender","my_rating","avg_rating")]
  df <- df[order(df$read_at, decreasing = T),]
  df
}
plotBooksByGender <- function(df) {
  g <- ggplot(df, aes(x = year(read_at), fill=as.factor(author_gender)))
  g <- g + geom_bar()
  g <- g + ggtitle("# of Books Read By Gender")
  g <- g + xlab("Year") + ylab("# of Books")
  g <- g + scale_fill_hue(name="Gender")
  g
}
plotRatingsByGender <- function(df) {
  df <- df[,c("my_rating","avg_rating","author_gender")]
  df <- aggregate(value ~ variable + author_gender, melt(df, id="author_gender"), mean)
  g <- ggplot(df, aes(x = variable, y = value, fill = author_gender))
  g <- g + geom_bar(stat = "identity", position = "dodge")
  g <- g + ggtitle("Ratings By Gender")
  g <- g + xlab("My Rating vs Community Avg Rating") + ylab("Rating Value")
  g <- g + scale_fill_hue(name="Gender")
  g
}

# reading speed
dataPagesPerDay <- function(data) {
  keep <- !is.na(data$started_at) & !is.na(data$read_at)
  df <- data[keep, c("title","num_pages","started_at","read_at")]
  df$days_read <- as.Date(df$read_at) - as.Date(df$started_at) + 1
  df$pgs_perday <- df$num_pages / as.numeric(df$days_read)
  df
}
dataReadSpeed <- function(df) {
  df[is.na(df$pgs_perday),"pgs_perday"] <- 0
  df[is.na(df$num_pages),"num_pages"] <- 0
  dates <- seq.Date(from = as.Date(min(df$started_at, na.rm = T)), to = as.Date(max(df$read_at, na.rm = T)), by = "days")
  num_books <- sapply(dates, function(x) sum(between(x, df$started_at, df$read_at)))
  num_pages <- sapply(dates, function(x) sum(df[between(x, df$started_at, df$read_at),"pgs_perday"]))
  data.frame(date = dates, num_books, num_pages)
}
plotPagesPerDay <- function(df) {
  rs <- dataReadSpeed(df)
  g <- ggplot(rs, aes(x = date, y = num_pages, fill=as.factor(num_books))) + geom_bar(stat="identity")
  g <- g + ggtitle("Pages Read per Day")
  g <- g + xlab("Date") + ylab("# Pages Read")
  g <- g + scale_fill_hue(name="Concurrent Books")
  g
}
summaryReadSpeed <- function(df) {
  rs <- dataReadSpeed(df)
  s <- c()
  s <- c(s, paste("You are reading a book about ",round(100*sum(rs$num_books>0)/nrow(rs)),"% of the time."))
  s <- c(s, paste("Your average reading speed (on reading days) is about",round(mean(rs[rs$num_books>0,"num_pages"], na.rm = T)),"pages per day."))
  s <- c(s, paste("If we include non-reading days, your speed is about",round(mean(rs$num_pages, na.rm = T)),"pages per day."))
  s <- c(s, paste("It takes you an average of",round(as.numeric(mean(df$days_read))),"days to finish a book."))
  s <- c(s, paste("You read books averaging",round(mean(df$num_pages, na.rm = T)),"pages long."))
  s <- c(s, paste("These numbers may be low because some books' page counts are not available on Goodreads."))
  s <- c(s, paste("All statistics based on your Goodreads activity."))
  paste(s, collapse = " ")
}
between <- function(x, a, b) {
  x >= a & x <= b
}

year <- function(str) {
  substring(str, 0, 4)
}

if (F) {
  userId <- 31656053;
  data <- getData(userId);
}