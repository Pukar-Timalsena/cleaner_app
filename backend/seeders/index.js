const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/User');
const Service = require('../models/Service');

dotenv.config();

// Connect to DB
mongoose.connect(process.env.MONGODB_URI);

const users = [
  {
    name: 'Test Customer',
    email: 'user@test.com',
    password: 'user123',
    phone: '+977 9841234567',
    address: 'Kathmandu, Nepal',
    role: 'customer'
  },
  {
    name: 'Test Admin',
    email: 'admin@test.com',
    password: 'admin123',
    phone: '+977 9841234568',
    address: 'Kathmandu, Nepal',
    role: 'admin'
  },
  {
    name: 'Jane Cleaner',
    email: 'cleaner@test.com',
    password: 'cleaner123',
    phone: '+977 9841234569',
    address: 'Kathmandu, Nepal',
    role: 'cleaner',
    experience: '3 years',
    rating: 4.8,
    totalJobs: 45
  },
  {
    name: 'John Smith',
    email: 'cleaner2@test.com',
    password: 'cleaner123',
    phone: '+977 9841234570',
    address: 'Lalitpur, Nepal',
    role: 'cleaner',
    experience: '5 years',
    rating: 4.9,
    totalJobs: 87
  }
];

const services = [
  {
    title: 'House Cleaning',
    description: 'Complete house cleaning service including all rooms, kitchen, and bathrooms. Our professional cleaners will make your home spotless.',
    category: 'house-cleaning',
    image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    basePrice: 1500,
    location: 'Kathmandu, Nepal',
    rating: 4.5,
    reviewCount: 124,
    estimatedTime: '2-3 hours'
  },
  {
    title: 'Carpet Cleaning',
    description: 'Deep carpet cleaning service using professional equipment. Remove stains, dirt, and allergens from your carpets.',
    category: 'carpet-cleaning',
    image: 'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac',
    basePrice: 1500,
    location: 'Kathmandu, Nepal',
    rating: 4.3,
    reviewCount: 89,
    estimatedTime: '1-2 hours'
  },
  {
    title: 'Window Cleaning',
    description: 'Professional window cleaning service for residential and commercial properties. Streak-free shine guaranteed.',
    category: 'window-cleaning',
    image: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50',
    basePrice: 1200,
    location: 'Kathmandu, Nepal',
    rating: 4.6,
    reviewCount: 67,
    estimatedTime: '1-2 hours'
  },
  {
    title: 'Sanitary Cleaning',
    description: 'Deep sanitization and cleaning service for bathrooms and toilets. Complete disinfection using professional-grade products.',
    category: 'sanitary-cleaning',
    image: 'https://images.unsplash.com/photo-1585421514738-01798e348b17',
    basePrice: 1500,
    location: 'Kathmandu, Nepal',
    rating: 4.7,
    reviewCount: 156,
    estimatedTime: '1-2 hours'
  },
  {
    title: 'House Painting',
    description: 'Professional house painting service for interior and exterior walls. Quality workmanship with premium paints.',
    category: 'house-painting',
    image: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828',
    basePrice: 1500,
    location: 'Kathmandu, Nepal',
    rating: 4.4,
    reviewCount: 92,
    estimatedTime: '1-2 days'
  }
];

const importData = async () => {
  try {
    await User.deleteMany();
    await Service.deleteMany();

    const createdUsers = await User.create(users);
    await Service.create(services);

    console.log('Data Imported!');
    console.log('\nTest Credentials:');
    console.log('Customer: user@test.com / user123');
    console.log('Admin: admin@test.com / admin123');
    console.log('Cleaner: cleaner@test.com / cleaner123');
    process.exit();
  } catch (error) {
    console.error(`Error: ${error}`);
    process.exit(1);
  }
};

const destroyData = async () => {
  try {
    await User.deleteMany();
    await Service.deleteMany();

    console.log('Data Destroyed!');
    process.exit();
  } catch (error) {
    console.error(`Error: ${error}`);
    process.exit(1);
  }
};

if (process.argv[2] === '-d') {
  destroyData();
} else {
  importData();
}
