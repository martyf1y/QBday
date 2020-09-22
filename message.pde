void updateMessage() {
  if (wordTimer < millis()-wordEndTime) {
    if (!waitType && !runAway) {
      newColor = QColor[int(random(0, 5))];
      int ranType = int(random(0, 9));
      if (ranType <= 3) {
        refreshTweets();
        
          String finalTwit = theTweets[currentTweet];
          
          currentTweet = currentTweet + 1;
          if (currentTweet > tweets.size()-1) {
            thisTwit = defaultMessage;
          currentTweet = 0;
          }
          if (finalTwit == null) {
            thisTwit = defaultMessage;
          } else {

            thisTwit = finalTwit;      
          }
      } else if (ranType <= 7) {
        thisTwit = txtMessages[txtcount];
        txtcount ++;
        if(txtcount > txtMessages.length-1){
          txtcount = 0;
        }
      } else if(ranType <= 8){
        thisTwit = defaultMessage;
      }
      stringCount = 0;
      nextWord(thisTwit);
      waitType = true;
    } else {
      waitType = false;
      goAgain = true;
    }
  }

  if (waitType && !runAway) {    
    runAway = printMessage();
    fade = 255;
  }
}

boolean printMessage() {
  if (stringCount < thisTwit.length()) {
    stringCount ++; 
    String typeTwit = thisTwit.substring(0, stringCount);
    message = typeTwit;
  } else if (stringCount >= thisTwit.length()) {
    return true;
  }
  // println("Still?");
  delay(40);
  return false;
}

void getNewTweets()
{
  try {
    // try to get tweets here
    Query query = new Query(searchString);
    query.setCount(10);
    QueryResult result = twitter.search(query);
    tweets = result.getTweets();
    updateCount++ ;
    int i = 0;
    for (Status status : tweets) {
        System.out.println("@" + status.getUser().getScreenName() + ":" + status.getText());
        theTweets[i] = "@" + status.getUser().getScreenName() + " - " + status.getText();
        i++;
    }
  }
  catch (TwitterException te) {
    // deal with the case where we can't get them here
    System.out.println("Failed to search tweets: " + te.getMessage());
    System.exit(-1);
  }
  counterTwit ++;
}

void refreshTweets()
{
  if (goAgain) {
    // while (true) {
    getNewTweets();
    println("Updated Tweets");
    println("currentzzzz" + tweets.size());

    //delay(100);
    goAgain = false;
    // }
  }
}