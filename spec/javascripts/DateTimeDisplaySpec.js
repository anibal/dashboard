describe("Date Time Display", function() {

  var tick_clock_timeout;

  beforeEach(function() {
    loadFixtures('date-time.html');
    fixed_date = new Date( 2011, 4, 18, 14, 53, 58);
    spyOn(window, 'Date').andReturn( fixed_date );    
    tick_clock_timeout = tickClock();
  });

  beforeEach(function() {
    clearTimeout(tick_clock_timeout);
  });

  it("should update the .date div with the date", function() {
    expect($('.date')).toHaveText('Wednesday, May 18, 2011');
  });

  it("should update the .time div with the time", function() {
    expect($('.time')).toHaveText('14:53:58');
  });
  
});
