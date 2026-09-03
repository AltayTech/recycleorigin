/// Minimal JSON matching [Customer.fromJson] for API mocks.
Map<String, dynamic> sampleCustomerJson({
  int id = 42,
  String firstName = 'Ada',
  String lastName = 'Lovelace',
  String email = 'ada@example.com',
}) {
  return <String, dynamic>{
    'id': id,
    'money': '99.50',
    'status': <String, dynamic>{'term_id': 1, 'name': 'ok', 'slug': 'ok'},
    'customer_type': <String, dynamic>{
      'term_id': 2,
      'name': 'individual',
      'slug': 'individual',
    },
    'customer_data': <String, dynamic>{
      'fname': firstName,
      'lname': lastName,
      'email': email,
      'phone': '',
      'ostan': '',
      'city': '',
      'mobile': '',
      'postcode': '',
    },
  };
}
