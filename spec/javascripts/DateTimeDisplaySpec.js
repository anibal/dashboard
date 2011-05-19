describe("Date/Time display update", function() {

  var tick_clock_timeout;

  beforeEach(function() {
    loadFixtures('date-time.html');
  });

  beforeEach(function() {
    clearTimeout(tick_clock_timeout);
  });

  it("should periodically update the time", function() {

    runs(function () {
      tickClock();
      this.displayed_time = $('.time').text();
    });

    waits(201);

    runs(function () {
      expect( this.displayed_time ).not.toEqual( $('.time') );
    });

  });
  
  describe("format", function() {

    beforeEach(function() {
      fixed_date = new Date( 2011, 4, 18, 14, 53, 58);
      spied_date = spyOn(window, 'Date').andReturn( fixed_date );
      tick_clock_timeout = tickClock();
    });

    beforeEach(function() {
      clearTimeout(tick_clock_timeout);
    });

    it("should be 'Day of week, Month Day, Year' for date", function() {
      expect($('.date')).toHaveText('Wednesday, May 18, 2011');
    });

    it("should be 'hh:mm:ss' for time", function() {
      expect($('.time')).toHaveText('14:53:58');
    });

  });

});
