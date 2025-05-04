import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// This file defines the `WasteRequestDateScreen` widget, which is a part of the waste feature presentation layer.
///
/// The screen allows users to select a date and time for waste collection. It includes the following key components:
///
/// - **Date Selection**: A scrollable list of dates displayed in a card-like UI. The selected date is highlighted.
/// - **Time Selection**: A horizontal list of available collection hours. The selected time is highlighted.
/// - **Continue Button**: A button that navigates to the next screen if a date is selected. If the user is not logged in, a login dialog is shown.
/// - **Loading Indicator**: Displays a loading spinner when data is being fetched.
/// - **Background and Drawer**: Includes a custom background and a side drawer for navigation.
///
/// Key Features:
/// - Uses `Consumer` to fetch and display data from the `AuthenticationProvider`.
/// - Highlights the selected date and time using conditional styling.
/// - Displays a snackbar if the user attempts to proceed without selecting a date.
/// - Handles user interactions such as date and time selection and navigation.
///
/// Dependencies:
/// - `AppTheme`: Provides theme colors and styles.
/// - `EnArConvertor`: Converts numbers and text between English and Arabic.
/// - `AuthenticationProvider`: Supplies region data for available collection hours.
/// - `ButtonBottom`: A custom button widget.
/// - `SpinKitFadingCircle`: A loading spinner widget.
/// - `MainDrawer`: A custom navigation drawer widget.
///
/// Navigation:
/// - Navigates to `WasteRequestSendScreen` upon successful date and time selection.
///
/// Note:
/// - Ensure that the `AuthenticationProvider` is properly configured to supply region data.
/// - The `AppTheme` and `EnArConvertor` should be implemented to match the app's design and localization requirements.
class AppBackground {
  static AssetImage getBackGroundImage() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk').format(now);
    if (6 > int.parse(formattedDate)) {
      return const AssetImage('assets/images/bg_1.jpg');
    } else if (18 > int.parse(formattedDate)) {
      return const AssetImage('assets/images/bg_2.jpg');
    } else {
      return const AssetImage('assets/images/bg_2.jpg');
    }
  }

  static Image setIconForMain(description) {
    if (description == "clear sky") {
      return const Image(
          image: AssetImage(
        'assets/images/icons8-sun-96.png',
      ));
    } else if (description == "few clouds") {
      return const Image(
          image: AssetImage('assets/images/icons8-partly-cloudy-day-80.png'));
    } else if (description.contains("clouds")) {
      return const Image(
          image: AssetImage('assets/images/icons8-clouds-80.png'));
    } else if (description.contains("thunderstorm")) {
      return const Image(
          image: AssetImage('assets/images/icons8-storm-80.png'));
    } else if (description.contains("drizzle")) {
      return const Image(
          image: AssetImage('assets/images/icons8-rain-cloud-80.png'));
    } else if (description.contains("rain")) {
      return const Image(
          image: AssetImage('assets/images/icons8-heavy-rain-80.png'));
    } else if (description.contains("snow")) {
      return const Image(image: AssetImage('assets/images/icons8-snow-80.png'));
    } else {
      return const Image(
          image: AssetImage('assets/images/icons8-windy-weather-80.png'));
    }
  }
}
