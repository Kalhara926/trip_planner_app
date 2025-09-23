// File: lib/services/ai_service.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart'; // GeoPoint සඳහා import කිරීම
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/models/trip_model.dart';

class AiService {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<List<ItineraryItem>> generateItinerary({
    required Trip trip,
    required String interests,
  }) async {
    if (_apiKey == null) {
      print('API Key not found.');
      return [];
    }

    final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
    final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;
    final tripDates = List.generate(
      tripDays,
      (index) => trip.startDate.add(Duration(days: index)),
    );

    // --- Latitude සහ Longitude ඉල්ලීමට යාවත්කාලීන කළ Prompt එක ---
    final prompt =
        '''
    You are an expert travel planner. Create a detailed itinerary for a trip.
    
    Destination: ${trip.destination}
    Duration: $tripDays days
    Start Date: ${trip.startDate.toIso8601String().split('T')[0]}
    User Interests: $interests
    
    Provide the response as a valid JSON array of objects.
    Each object in the array represents an itinerary event and MUST have the following keys: "day", "time", "description", "latitude", and "longitude".
    "latitude" and "longitude" MUST be numbers representing the geographic coordinates.
    "time" should be a string in "HH:mm" format.
    
    Example response format:
    [
      {"day": 1, "time": "10:00", "description": "Visit the main museum", "latitude": 6.9333, "longitude": 79.8500},
      {"day": 1, "time": "13:00", "description": "Lunch at a famous local restaurant", "latitude": 6.9271, "longitude": 79.8612}
    ]
    
    Now, generate the itinerary.
    ''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    if (response.text != null) {
      try {
        final List<dynamic> jsonResponse = jsonDecode(response.text!);
        List<ItineraryItem> itineraryItems = [];

        for (var item in jsonResponse) {
          int dayIndex = (item['day'] as int) - 1;
          if (dayIndex >= 0 && dayIndex < tripDates.length) {
            DateTime date = tripDates[dayIndex];
            List<String> timeParts = (item['time'] as String).split(':');
            int hour = int.parse(timeParts[0]);
            int minute = int.parse(timeParts[1]);

            itineraryItems.add(
              ItineraryItem(
                description: item['description'],
                time: DateTime(date.year, date.month, date.day, hour, minute),
                tripId: trip.id!,
                date: date,
                // AI එකෙන් ලැබෙන lat/lng වලින් GeoPoint object එකක් සෑදීම
                position: GeoPoint(item['latitude'], item['longitude']),
              ),
            );
          }
        }
        return itineraryItems;
      } catch (e) {
        print(
          "Error parsing AI response: $e \nResponse Text: ${response.text}",
        );
        return [];
      }
    }
    return [];
  }
}
