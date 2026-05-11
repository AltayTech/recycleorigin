import 'package:flutter/foundation.dart';
import 'package:recycleorigin/core/models/sizes.dart';

import 'social_media.dart';
import '../../../../core/models/feature.dart';
import '../../../../core/models/featured_image.dart';

class Shop with ChangeNotifier {
  final String support_phone;
  final FeaturedImage logo;
  final String return_policy;
  final String privacy;
  final String how_to_order;
  final String faq;
  final String pay_methods_desc;
  final String word_hours;
  final String address;
  final SocialMedia social_media;
  final String name;
  final String subject;
  final String slug;
  final String phone;
  final String mobile;
  final String about;
  final List<Feature> features_list;
  final FeaturedImage featured_image;
  final List<FeaturedImage> gallery;
  final String policy;

  Shop({
    this.support_phone = '',
    logo,
    this.return_policy = '',
    this.privacy = '',
    this.how_to_order = '',
    this.faq = '',
    this.pay_methods_desc = '',
    this.word_hours = '',
    this.address = '',
    social_media = '',
    this.name = '',
    this.subject = '',
    this.slug = '',
    this.phone = '',
    this.mobile = '',
    this.about = '',
    this.features_list = const [],
    featured_image,
    this.gallery = const [],
    this.policy = '',
  })  : this.logo = FeaturedImage(sizes: Sizes()),
        this.featured_image = FeaturedImage(sizes: Sizes()),
        this.social_media = SocialMedia(telegram: '', instagram: '');

  factory Shop.fromJson(Map<String, dynamic> parsedJson) {
    final galleryList = parsedJson['gallery'];
    final galleryRaw = galleryList is List
        ? galleryList
            .map((dynamic i) => FeaturedImage.fromJson(i))
            .toList()
        : <FeaturedImage>[];

    final featureList = parsedJson['features_list'];
    final featureRaw = featureList is List
        ? featureList.map((dynamic i) => Feature.fromJson(i)).toList()
        : <Feature>[];

    return Shop(
      support_phone: parsedJson['support_phone'] as String? ?? '',
      logo: FeaturedImage.fromJson(parsedJson['logo']),
      return_policy: parsedJson['return_policy'] as String? ?? '',
      privacy: parsedJson['privacy'] as String? ?? '',
      how_to_order: parsedJson['how_to_order'] as String? ?? '',
      faq: parsedJson['faq'] as String? ?? '',
      pay_methods_desc: parsedJson['pay_methods_desc'] as String? ?? '',
      word_hours: parsedJson['word_hours'] as String? ?? '',
      address: parsedJson['address'] as String? ?? '',
      social_media: SocialMedia.fromJson(parsedJson['social_media']),
      name: parsedJson['name'] as String? ?? '',
      subject: parsedJson['subject'] as String? ?? '',
      slug: parsedJson['slug'] as String? ?? '',
      phone: parsedJson['phone'] as String? ?? '',
      mobile: parsedJson['mobile'] as String? ?? '',
      about: parsedJson['about'] as String? ?? '',
      features_list: featureRaw,
      featured_image: FeaturedImage.fromJson(parsedJson['featured_image']),
      gallery: galleryRaw,
      policy: parsedJson['policy'] as String? ?? '',
    );
  }
}
