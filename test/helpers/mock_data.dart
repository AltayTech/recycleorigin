import 'package:recycleorigin/core/models/search_detail.dart';
import 'package:recycleorigin/core/models/customer.dart';
import 'package:recycleorigin/features/customer_feature/business/entities/personal_data.dart';

/// Mock data factory for creating test data
class MockData {
  /// Creates a mock SearchDetail
  static SearchDetail createSearchDetail({int maxPage = 10, int total = 100}) {
    return SearchDetail(max_page: maxPage, total: total);
  }

  /// Creates a mock Product JSON
  /// Note: Full Product entity creation requires many dependencies
  static Map<String, dynamic> createProductJson({
    int id = 1,
    String name = 'Test Product',
    String price = '1000',
  }) {
    return {
      'id': id,
      'name': name,
      'price': price,
      'featured_image': {
        'id': 1,
        'title': '',
        'sizes': {'medium': '', 'thumbnail': '', 'full': ''},
      },
    };
  }

  /// Creates a list of mock product JSONs
  static List<Map<String, dynamic>> createProductsJsonList({int count = 3}) {
    return List.generate(
      count,
      (index) => createProductJson(
        id: index + 1,
        name: 'Product ${index + 1}',
        price: '${(index + 1) * 1000}',
      ),
    );
  }

  /// Creates a mock ProductCart JSON
  static Map<String, dynamic> createProductCartJson({
    int id = 1,
    String title = 'Test Product',
    String price = '1000',
    int productCount = 1,
  }) {
    return {
      'id': id,
      'title': title,
      'price': price,
      'featured_media_url': '',
      'productCount': productCount,
    };
  }

  /// Creates a mock Category JSON
  static Map<String, dynamic> createCategoryJson({
    int id = 1,
    String name = 'Test Category',
  }) {
    return {'id': id, 'name': name, 'term_id': id, 'slug': 'test-category'};
  }

  /// Creates a list of mock category JSONs
  static List<Map<String, dynamic>> createCategoriesJsonList({int count = 3}) {
    return List.generate(
      count,
      (index) =>
          createCategoryJson(id: index + 1, name: 'Category ${index + 1}'),
    );
  }

  /// Creates a mock Customer
  static Customer createCustomer({
    String firstName = 'John',
    String lastName = 'Doe',
    String email = 'john.doe@example.com',
    String phone = '+1234567890',
    String money = '1000',
  }) {
    return Customer(
      personalData: PersonalData(
        first_name: firstName,
        last_name: lastName,
        email: email,
        phone: phone,
        ostan: 'Test Province',
        city: 'Test City',
        postcode: '12345',
      ),
      money: money,
    );
  }

  /// Creates a mock JSON response for products
  static Map<String, dynamic> createProductsJsonResponse({
    int count = 3,
    int maxPage = 10,
    int total = 100,
  }) {
    return {
      'products': List.generate(
        count,
        (index) => {
          'id': index + 1,
          'name': 'Product ${index + 1}',
          'price': '${(index + 1) * 1000}',
        },
      ),
      'productsDetail': {'max_page': maxPage, 'total': total},
    };
  }

  /// Creates a mock JSON response for categories
  static List<Map<String, dynamic>> createCategoriesJsonResponse({
    int count = 3,
  }) {
    return List.generate(
      count,
      (index) => {'id': index + 1, 'name': 'Category ${index + 1}'},
    );
  }
}
