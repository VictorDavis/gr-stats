# gr-stats
Uses Goodreads API to download reading stats and display metrics in a Shiny App.

## Description
Visit the [shiny app](https://victor.shinyapps.io/gr-stats/) to see the program in motion. The app accepts a [Goodreads profile URL](http://www.goodreads.com/author/show/8282486.Victor_A_Davis), auto detects whether it is an author or a user profile, and extracts user id. The server files use [Daniel Wood's Goodreads API wrapper](https://github.com/victordavis/goodreads-api) to convert author id to user id (gr-auth.php) and to download a csv of a user's reading activity (gr-stats.php). The shiny app then slices & dices the information into interactive graphs.

This is just a start. I hope to add many more metrics in the future!
