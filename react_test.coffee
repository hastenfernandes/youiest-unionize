Tinytest.add 'reactjs - dom element equals to data', (test, next) -> #addAsync
  testingRecommend = { from: 'another1', to: 'wiber' }
  connect(testingRecommend)
  testingRecommend = { from: 'another2', to: 'wiber' }
  connect(testingRecommend)
  testingRecommend = { from: 'another3', to: 'wiber' }
  connect(testingRecommend)
  testingRecommend = { from: 'another4', to: 'wiber' }
  connect(testingRecommend)
  testingRecommend = { from: 'another5', to: 'wiber' }
  connect(testingRecommend)
  intervalId = null
  # intervalId = setInterval(()->
  domString = React.renderComponentToString(FeedList(null))
  # console.error(domString)
  if domString.match(testingRecommend.from)
  # if domString.match("failingtest")
    alert("newdata")
    test.equal(true,true, "found match for "+testingRecommend.from)
    # next()
  else
    test.equal(false,true, "match failed for failingtest")
    # clearInterval(intervalId)
  # , 1000)