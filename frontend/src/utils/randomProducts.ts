import { RandomProduct } from '../types';

export const productCategories = [
  'electronics',
  'clothing',
  'books',
  'home',
  'sports',
  'beauty',
  'food',
  'other'
];

export const productNames = {
  electronics: [
    'Smartphone', 'Laptop', 'Tablet', 'Headphones', 'Smart Watch',
    'Bluetooth Speaker', 'Gaming Console', 'Camera', 'Drone', 'VR Headset'
  ],
  clothing: [
    'T-Shirt', 'Jeans', 'Sneakers', 'Jacket', 'Dress',
    'Hoodie', 'Sweater', 'Shorts', 'Boots', 'Hat'
  ],
  books: [
    'Novel', 'Textbook', 'Cookbook', 'Biography', 'Mystery',
    'Science Fiction', 'Romance', 'Thriller', 'Fantasy', 'History'
  ],
  home: [
    'Coffee Maker', 'Vacuum Cleaner', 'Lamp', 'Cushion', 'Plant Pot',
    'Wall Clock', 'Mirror', 'Rug', 'Curtains', 'Candles'
  ],
  sports: [
    'Basketball', 'Tennis Racket', 'Yoga Mat', 'Running Shoes', 'Dumbbells',
    'Bicycle', 'Swimming Goggles', 'Golf Clubs', 'Soccer Ball', 'Fitness Tracker'
  ],
  beauty: [
    'Face Cream', 'Lipstick', 'Shampoo', 'Perfume', 'Nail Polish',
    'Sunscreen', 'Moisturizer', 'Mascara', 'Foundation', 'Serum'
  ],
  food: [
    'Organic Honey', 'Coffee Beans', 'Olive Oil', 'Chocolate', 'Tea',
    'Granola', 'Protein Bar', 'Spices', 'Vinegar', 'Nuts'
  ],
  other: [
    'Gift Card', 'Art Print', 'Phone Case', 'Keychain', 'Bookmark',
    'Sticker Pack', 'Magnets', 'Poster', 'Calendar', 'Notebook'
  ]
};

export const productDescriptions = {
  electronics: [
    'High-quality electronic device with advanced features',
    'Latest technology with premium build quality',
    'Innovative design with excellent performance',
    'Professional-grade equipment for everyday use',
    'Smart device with cutting-edge technology'
  ],
  clothing: [
    'Comfortable and stylish clothing item',
    'Premium quality fabric with modern design',
    'Versatile piece perfect for any occasion',
    'Durable construction with attention to detail',
    'Trendy design with superior comfort'
  ],
  books: [
    'Engaging read with compelling storytelling',
    'Educational content with practical insights',
    'Well-researched material with clear explanations',
    'Inspiring narrative with valuable lessons',
    'Comprehensive guide with expert knowledge'
  ],
  home: [
    'Beautiful home decor item to enhance your space',
    'Functional design with aesthetic appeal',
    'Quality craftsmanship for lasting enjoyment',
    'Modern style that complements any interior',
    'Practical solution with elegant appearance'
  ],
  sports: [
    'Professional-grade sports equipment',
    'Durable construction for active lifestyle',
    'Performance-enhancing gear for athletes',
    'Comfortable design for extended use',
    'High-quality materials for optimal results'
  ],
  beauty: [
    'Premium beauty product with natural ingredients',
    'Luxurious formula for radiant results',
    'Professional-grade cosmetics for everyday use',
    'Gentle formula suitable for all skin types',
    'Innovative beauty solution with proven results'
  ],
  food: [
    'Organic and natural food product',
    'Premium quality ingredients for healthy living',
    'Artisanal product with authentic flavor',
    'Nutritious option for conscious consumers',
    'Fresh and delicious food item'
  ],
  other: [
    'Unique and useful item for everyday life',
    'Creative design with practical functionality',
    'Quality product with attention to detail',
    'Versatile item with multiple uses',
    'Special product for memorable experiences'
  ]
};

export function generateRandomProduct(): RandomProduct {
  const category = productCategories[Math.floor(Math.random() * productCategories.length)];
  const names = productNames[category as keyof typeof productNames];
  const descriptions = productDescriptions[category as keyof typeof productDescriptions];
  
  const name = names[Math.floor(Math.random() * names.length)];
  const description = descriptions[Math.floor(Math.random() * descriptions.length)];
  
  // Generate random price between $5 and $500
  const price = Math.round((Math.random() * 495 + 5) * 100) / 100;
  
  // Generate random quantity between 1 and 100
  const quantity = Math.floor(Math.random() * 100) + 1;

  return {
    name,
    description,
    price,
    category,
    quantity
  };
}

export function generateRandomProductWithVariations(): RandomProduct {
  const baseProduct = generateRandomProduct();
  
  // Add some variations to make products more unique
  const variations = [
    'Premium', 'Deluxe', 'Pro', 'Elite', 'Standard', 'Basic',
    'Limited Edition', 'Special', 'Exclusive', 'Signature'
  ];
  
  const colors = [
    'Black', 'White', 'Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange',
    'Pink', 'Gray', 'Brown', 'Silver', 'Gold'
  ];
  
  const sizes = ['Small', 'Medium', 'Large', 'Extra Large'];
  
  // Randomly add variation
  if (Math.random() < 0.3) {
    const variation = variations[Math.floor(Math.random() * variations.length)];
    baseProduct.name = `${variation} ${baseProduct.name}`;
  }
  
  // Randomly add color
  if (Math.random() < 0.4) {
    const color = colors[Math.floor(Math.random() * colors.length)];
    baseProduct.name = `${color} ${baseProduct.name}`;
  }
  
  // Randomly add size for clothing
  if (baseProduct.category === 'clothing' && Math.random() < 0.5) {
    const size = sizes[Math.floor(Math.random() * sizes.length)];
    baseProduct.name = `${baseProduct.name} (${size})`;
  }

  return baseProduct;
}
