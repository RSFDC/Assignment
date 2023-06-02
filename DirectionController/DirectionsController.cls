public with sharing class DirectionsController {
  private static String vHash = 'UmFnaGF2ZW5kcmEgWWFkYXZhbGxp';

  @AuraEnabled(cacheable=true)
  public static DirectionsResult getDirections(String originAddress, String destinationAddress) {
    // Validate input addresses
    if (String.isBlank(originAddress) || String.isBlank(destinationAddress)) {
      throw new AuraHandledException('Origin and destination addresses are required.');
    }

    // Calculate distance and travel time using Google Maps API
    Double distance = calculateDistance(originAddress, destinationAddress);
    Integer travelTime = calculateTravelTime(originAddress, destinationAddress);

    // Calculate cost of travel based on rates from Custom Metadata Type
    Decimal costOfTravel = calculateCostOfTravel(distance);

    // Prepare and return the result as a custom object
    DirectionsResult result = new DirectionsResult();
    result.distance = distance;
    result.travelTime = travelTime;
    result.costOfTravel = costOfTravel;
    return result;
  }


private static Double calculateDistance(String originAddress, String destinationAddress) {
  // Make API call to Google Maps Distance Matrix API to calculate the distance
  String apiUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial';
  String apiKey = 'AIzaSyAQwps3tEEKKLYXZ1kegePbzlUrnc8VRHs'; // Actual API key

  // Build the API request URL
  String requestUrl = apiUrl + '&origins=' + EncodingUtil.urlEncode(originAddress, 'UTF-8')
    + '&destinations=' + EncodingUtil.urlEncode(destinationAddress, 'UTF-8')
    + '&key=' + EncodingUtil.urlEncode(apiKey, 'UTF-8');

  // Send the HTTP request
  Http http = new Http();
  HttpRequest request = new HttpRequest();
  request.setEndpoint(requestUrl);
  request.setMethod('GET');
  HttpResponse response = http.send(request);

  // Parse the API response and extract the distance value
  Double distance = 0.0;

  if (response.getStatusCode() == 200) {
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

    // Check if the response contains valid data
    if (responseMap.containsKey('rows') && responseMap.get('rows') instanceof List<Object>) {
      List<Object> rows = (List<Object>) responseMap.get('rows');
      if (!rows.isEmpty() && rows[0] instanceof Map<String, Object>) {
        Map<String, Object> rowData = (Map<String, Object>) rows[0];
        if (rowData.containsKey('elements') && rowData.get('elements') instanceof List<Object>) {
          List<Object> elements = (List<Object>) rowData.get('elements');
          if (!elements.isEmpty() && elements[0] instanceof Map<String, Object>) {
            Map<String, Object> elementData = (Map<String, Object>) elements[0];
            if (elementData.containsKey('distance') && elementData.get('distance') instanceof Map<String, Object>) {
              Map<String, Object> distanceData = (Map<String, Object>) elementData.get('distance');
              if (distanceData.containsKey('value') && distanceData.get('value') instanceof Double) {
                distance = (Double) distanceData.get('value');
              }
            }
          }
        }
      }
    }
  }

  return distance;
}


private static Integer calculateTravelTime(String originAddress, String destinationAddress) {
  // Make API call to Google Maps Directions API to calculate the travel time
  String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  String apiKey = 'AIzaSyAQwps3tEEKKLYXZ1kegePbzlUrnc8VRHs'; // Actual API key

  // Build the API request URL
  String requestUrl = apiUrl + '?origin=' + EncodingUtil.urlEncode(originAddress, 'UTF-8')
    + '&destination=' + EncodingUtil.urlEncode(destinationAddress, 'UTF-8')
    + '&key=' + EncodingUtil.urlEncode(apiKey, 'UTF-8');

  // Send the HTTP request
  Http http = new Http();
  HttpRequest request = new HttpRequest();
  request.setEndpoint(requestUrl);
  request.setMethod('GET');
  HttpResponse response = http.send(request);

  // Parse the API response and extract the travel time value
  Integer travelTime = 0;

  if (response.getStatusCode() == 200) {
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

    // Check if the response contains valid data
    if (responseMap.containsKey('routes') && responseMap.get('routes') instanceof List<Object>) {
      List<Object> routes = (List<Object>) responseMap.get('routes');
      if (!routes.isEmpty() && routes[0] instanceof Map<String, Object>) {
        Map<String, Object> routeData = (Map<String, Object>) routes[0];
        if (routeData.containsKey('legs') && routeData.get('legs') instanceof List<Object>) {
          List<Object> legs = (List<Object>) routeData.get('legs');
          if (!legs.isEmpty() && legs[0] instanceof Map<String, Object>) {
            Map<String, Object> legData = (Map<String, Object>) legs[0];
            if (legData.containsKey('duration') && legData.get('duration') instanceof Map<String, Object>) {
              Map<String, Object> durationData = (Map<String, Object>) legData.get('duration');
              if (durationData.containsKey('value') && durationData.get('value') instanceof Integer) {
                travelTime = (Integer) durationData.get('value');
              }
            }
          }
        }
      }
    }
  }

  return travelTime;
}


private static Decimal calculateCostOfTravel(Double distance) {
  // Fetch rates from Custom Metadata Type
  Rate__mdt[] rates = [SELECT Rate_Per_Mile__c FROM Rate__mdt WHERE Mode__c = 'Bus' LIMIT 1];
  
  // Check if rates exist
  if (rates.isEmpty()) {
    throw new AuraHandledException('Rates are not available.');
  }

  Decimal ratePerMile = rates[0].Rate_Per_Mile__c;

  // Validate rate per mile
  if (ratePerMile <= 0) {
    throw new AuraHandledException('Invalid rate per mile.');
  }
  
  // Calculate the cost of travel based on the distance and rate per mile
  Decimal costOfTravel = distance * ratePerMile;
  return costOfTravel;
}

public class DirectionsResult {
  @AuraEnabled public Double distance;
  @AuraEnabled public Integer travelTime;
  @AuraEnabled public Decimal costOfTravel;
}
}