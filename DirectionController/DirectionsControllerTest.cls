@IsTest
private class DirectionsControllerTest {

  @IsTest
  static void testGetDirections() {
    // Test data
    String originAddress = '123 Main St';
    String destinationAddress = '456 Elm St';

    // Mock HTTP callout
    Test.setMock(HttpCalloutMock.class, new DirectionsControllerMock());

    // Call the method to test
    DirectionsController.DirectionsResult result = DirectionsController.getDirections(originAddress, destinationAddress);

    // Verify the result
    System.assertEquals(10000.0, result.distance, 'Incorrect distance');
    System.assertEquals(30, result.travelTime, 'Incorrect travel time');
    System.assertEquals(100.0, result.costOfTravel, 'Incorrect cost of travel');
  }
  
  // Mock HTTP response
  private class DirectionsControllerMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{"rows":[{"elements":[{"distance":{"value":10000},"duration":{"value":1800}}]}]}');
      response.setStatusCode(200);
      return response;
    }
  }
}
