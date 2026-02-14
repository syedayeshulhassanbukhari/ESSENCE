import '../models/marketplace_product.dart';
import '../theme/app_theme.dart';

class MarketplaceCatalogProvider {
  final List<MarketplaceProduct> _products = const [
    MarketplaceProduct(
      name: 'Electric Petal',
      category: 'Floral / Ozone / Neon',
      priceLabel: '\$120',
      priceValue: 120,
      bgColor: AppTheme.accentCyan,
      isBestSeller: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuARs5-kfpCkWenceZ4aVeTZBLINXYN5TQ7QfgZIYXrK0wbuwN7j48MS3qlAJcBDt799iQt8MzEzVJaPAoqC4OlQaCuW9jFnFZGBKstfgKBxgRWNXE-LHmRSJYrkgo_b9yNS0_YteyXnIwHBnn2oE782sHsbUxm_3KqoeVXoApkCIwDtOw5dd2LPUqWigyHFO43aYJ6tePM6gzIQn2M3VkAP24GhIme6q5qOCXbkPJGuG9IXRc1_sa4EZ__HlrB0W2t4GqhFdx5mebU',
    ),
    MarketplaceProduct(
      name: 'Nuclear Amber',
      category: 'Resin / Smoke / Static',
      priceLabel: '\$185',
      priceValue: 185,
      bgColor: AppTheme.accentPink,
      isBestSeller: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBLgv9lyr1-brQGNHgQG6tR_hJ81FSd9zTcoLc91-g7GiH_q2P-JMEX9M8XI6fZePHQxBAPqmr36HshXvXggl3l2rEjikdAr2QHirTHMUlkx8wwL28jr9-56JxkRMQJaGjvEjAsMKGWq3svotmf0rXVZdgNtECSy1FxKGJ2QA45_wQ7GYRwBIzreMxz8dPMuddfbcTExTQTHFzJI-E_C7ZrYCMKJlgxjCZvru5yO0r4ih4l3_CcQho9ycN6Velg51dX8SYEuvdGTaA',
    ),
    MarketplaceProduct(
      name: 'Void Water',
      category: 'Mineral / Cold / Salt',
      priceLabel: '\$95',
      priceValue: 95,
      bgColor: AppTheme.primaryYellow,
      isBestSeller: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDa1xa1NBBpMxGxPUsAjLSEfNiPKdQlN5ITpVIHuxQI2N0Ny6vbw7obEHuj8XkgoFPBcAYmPfMufMd-_4YnftXzCtno66LNHfd0oabiYDIFiAQzYC-l4Koffy-33zcktnk1R0ZEsdsRH4HCUotVZOVVLQYyWpMO0Su9Mr_mD9CXw5jnfqJRAL6lxwZfQQK58UGhqElLldhI8NE8DifWTiO2DJkfqWbPmP2bf2U0ffc0JNZsZIWteFfmXeo21gOD0CZV20i-bALc3mg',
    ),
    MarketplaceProduct(
      name: 'Glitch Moss',
      category: 'Damp Earth / Chrome / Ink',
      priceLabel: '\$145',
      priceValue: 145,
      bgColor: AppTheme.accentGreen,
      isBestSeller: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3cCICX72C5L10hxqMD3G-g2tagOlIAl21xzH1-Yyy2F3-tFAFLmoc12iB0fCji3ZCf8WY8MswLO7czBhasEpkRVMcCOu32j_VN5XoJ7ttb1RA1lfHs_lSrdl3AQnYE_v2GdN4bJ3dMyxWU-qLqddhAl8NKdGT4Z0d9lqHrbXEiKDwOLU8BxWye8l9vWCHmH-nOHhcFprnik18IeGH14i5gekhgUTzOqpI11636v6D1gGdSp_xcnp6WcqWBTC4QlfBgVKjZA4uiiQ',
    ),
    MarketplaceProduct(
      name: 'Abstract Paper',
      category: 'White Musk / Wood / Fiber',
      priceLabel: '\$210',
      priceValue: 210,
      bgColor: AppTheme.white,
      isBestSeller: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA48d_GqQgG9YJ07wXYZ3Ln147KcogzlTsKLut7nbCiqRV6AkOXMRy95ac8WX_g5FfPYZyi8cYV0G2-vL3GpTTgvObMdMhB-s32sDnZ6OyKqPcl81sDjt1GiXkYTPKSLkkXXISRR7y148N1wLP2VFor-6uxiF0b3L4BzeBANVSfA5pcaz-dEWG-PyobdkNGkw5KjYuJz3N_MGiUjlp09k6-Gf7yvJpMT8T_uSB0V6Ll0knQayEiOeaLXOzr9FGDthf1vyOInqLsiM8',
    ),
    MarketplaceProduct(
      name: 'Black Hole',
      category: 'Darkness / Velvet / Gravity',
      priceLabel: '\$300',
      priceValue: 300,
      bgColor: AppTheme.black,
      isBestSeller: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC-ue9Zo4tuPHerU0y_VtwqkqguXgv5Ub48_u-A9MZYc90_E-_dQx6PH7ELhwPUFAsZdrV8LnkvDdF4LI8HUSWDx6Fk_cUa0VLBhUsoS7tTV4xbYrNor3u_FDQ9Pjxgg7u-BHC7Uu7ifmyYLZEleuRhWDOtJ1e5isYj9WQYVpctncg12LOZEH0-rv_WWj7izR1_DjN2fgAaH3eJ8Q1he83JFMFe8vtvarkFnaEVYYFixCeZg2HmBhQzGvz7rOuMbPPrXdn2E7w1nRo',
    ),
  ];

  List<MarketplaceProduct> get products => List.unmodifiable(_products);
}
