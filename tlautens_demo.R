require(quantstrat)

suppressWarnings(rm("order_book.macd",pos=.strategy))
suppressWarnings(rm("account.macd","portfolio.macd",pos=.blotter))
suppressWarnings(rm("account.st","portfolio.st","stock.str","stratMACD","initDate","initEq",'start_t','end_t'))

#correct for TZ issues if they crop up
oldtz<-Sys.getenv('TZ')

if(oldtz=='') {Sys.setenv(TZ="GMT")}

# stock.str='GDAXI' # what are we trying it on
stock.str='GDAX2015'

#MA parameters for MACD
fastMA = 12
slowMA = 26
signalMA = 10
maType="EMA"

currency('EUR')

stock(stock.str,currency='USD',multiplier=1)


 #or use fake data
   #stock.str='sample_matrix' # what are we trying it on
   #data(sample_matrix)                 # data included in package xts
   #sample_matrix<-as.xts(sample_matrix)
   
   ##### PLACE DEMO AND TEST DATES HERE #################
 #
   #if(isTRUE(options('in_test')$in_test))
   #  # use test dates
   #  {initDate="2011-01-01" 
   #  endDate="2012-12-31"   
   #  } else
   #  # use demo defaults
   #  {initDate="1999-12-31"
   #  endDate=Sys.Date()}
   
initDate='2006-12-31'
initEq=1000000

portfolio.st='macd'
account.st='macd'

initPortf(portfolio.st,symbols=stock.str, initDate=initDate)

initAcct(account.st,portfolios=portfolio.st, initDate=initDate, initEq = initEq)

initOrders(portfolio=portfolio.st,initDate=initDate)

strat.st<-portfolio.st

# define the strategy
strategy(strat.st, store=TRUE)

#one indicator
add.indicator(strat.st, name = "MACD", arguments = list(x=quote(Cl(mktdata))), label='_')


#two signals
add.signal(strat.st,name="sigThreshold", arguments = list(column="signal._", relationship="gt", threshold=0, cross=TRUE), label="signal.gt.zero")

add.signal(strat.st,name="sigThreshold", arguments = list(column="signal._", relationship="lt", threshold=0, cross=TRUE), label="signal.lt.zero")


####
# add rules
   
# entry
add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.gt.zero", sigval=TRUE, orderqty=100, ordertype='market', orderside='long', threshold=NULL), type='enter', label='enter', storefun=FALSE)

#alternatives for risk stops:
   # simple stoplimit order, with threshold multiplier
   #add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.gt.zero",sigval=TRUE, orderqty='all', ordertype='stoplimit', orderside='long', threshold=-.05,tmult=TRUE, orderset='exit2'),type='chain', parent='enter', label='risk',storefun=FALSE)
   # alternately, use a trailing order, also with a threshold multiplier
 add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.gt.zero",sigval=TRUE, orderqty='all', ordertype='stoptrailing', orderside='long', threshold=-23,tmult=FALSE, orderset='exit2'),	type='chain', parent='enter', label='trailingexit')
   
# exit
add.rule(strat.st,name='ruleSignal', arguments = list(sigcol="signal.lt.zero", sigval=TRUE, orderqty='all', ordertype='market',orderside='long',threshold=NULL, orderset='exit2'), type='exit',label='exit')

# getSymbols(stock.str,from=initDate)
start_t<-Sys.time()

out<-applyStrategy(strat.st , portfolios=portfolio.st,parameters=list(nFast=fastMA, nSlow=slowMA, nSig=signalMA,maType=maType),verbose=FALSE)

end_t<-Sys.time()
print(end_t-start_t)
start_t<-Sys.time()

updatePortf(Portfolio=portfolio.st,Dates=paste('::',as.Date(Sys.time()),sep=''))

end_t<-Sys.time()

print("trade blotter portfolio update:")

print(end_t-start_t)


 chart.Posn(Portfolio=portfolio.st,Symbol=stock.str)

 plot(add_MACD(fast=fastMA, slow=slowMA, signal=signalMA,maType="EMA"))

book<-getOrderBook('macd')
stats <- tradeStats('macd')
dailyStats <- dailyStats('macd', use = c("equity", "txns"))
rets  = PortfReturns(account.st)

# set tz as it was before the demo
Sys.setenv(TZ=oldtz)

#print(data.frame(t(stats[,-c(1,2)])))

#adx.sar <- SAR(GDAX2015[ ,c("GDAXI.High", "GDAXI.Low")])

##### PLACE THIS BLOCK AT END OF DEMO SCRIPT ################### 
# book  = getOrderBook(port)
# stats = tradeStats(port)
# rets  = PortfReturns(acct)