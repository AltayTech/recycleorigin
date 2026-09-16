import 'package:recycleorigin/core/models/featured_image.dart';
import 'package:recycleorigin/core/models/sizes.dart';
import 'package:recycleorigin/core/models/status.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/price_weight.dart';
import 'package:recycleorigin/features/waste_feature/business/entities/waste.dart';

/// Shared [Waste] samples for waste-feature tests.
Waste sampleWaste({int id = 1, String name = 'Test waste'}) {
  return Waste(
    id: id,
    name: name,
    excerpt: 'Excerpt',
    prices: <PriceWeight>[PriceWeight(weight: '1', price: '10')],
    status: Status(term_id: 1, name: 'Active', slug: 'active'),
    featured_image: FeaturedImage(id: 1, title: '', sizes: Sizes()),
  );
}
