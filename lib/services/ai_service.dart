// lib/services/ai_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:trip_planner_app/models/itinerary_item_model.dart';
import 'package:trip_planner_app/models/trip_model.dart';

class AiService {
  // Get API key from .env file
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<List<ItineraryItem>> generateItinerary({
    required Trip trip,
    required String interests,
  }) async {
    if (_apiKey == null) {
      print('API Key not found.');
      return [];
    }

    final model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey!);
    final tripDays = trip.endDate.difference(trip.startDate).inDays + 1;
    final tripDates = List.generate(
      tripDays,
      (index) => trip.startDate.add(Duration(days: index)),
    );

    // --- The Prompt ---
    final prompt =
        '''
    You are an expert travel planner. Create a detailed itinerary for a trip.
    
    Destination: ${trip.destination}
    Duration: $tripDays days
    Start Date: ${trip.startDate.toIso8601String().split('T')[0]}
    User Interests: $interests
    
    Provide the response as a valid JSON array of objects.
    Each object in the array represents an itinerary event and MUST have the following keys: "day", "time", and "description".
    "day" should be an integer (from 1 to $tripDays).
    "time" should be a string in "HH:mm" format (e.g., "09:00", "13:30").
    "description" should be a short, engaging description of the activity.
    
    Example response format:
    [
      {"day": 1, "time": "10:00", "description": "Visit the main museum"},
      {"day": 1, "time": "13:00", "description": "Lunch at a famous local restaurant"},
      {"day": 2, "time": "09:30", "description": "Hike to the waterfall"}
    ]
    
    Now, generate the itinerary.
    ''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    if (response.text != null) {
      try {
        // AI එකෙන් එන response එක JSON බවට පත්කිරීම
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
              ),
            );
          }
        }
        return itineraryItems;
      } catch (e) {
        print("Error parsing AI response: $e");
        return [];
      }
    }
    return [];
  }
}
