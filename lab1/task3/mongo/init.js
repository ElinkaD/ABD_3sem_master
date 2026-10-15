// Документы взяты из files/clients.json, files/restaurants.json

db = db.getSiblingDB('delivery');

db.clients.insertMany([
  {
    _id: ObjectId('727a81ce9a8cd1920741e258'),
    name: 'Иванова Инна Ивановна',
    phone: '5824585',
    email: 'iii@mail.ru',
    birthday: '30.04.2014',
    login: 'iii',
    address: { city: 'СПб', street: 'Московский пр', building: '12' },
    update_time: ISODate('2024-05-24T10:00:13Z'),
  },
  {
    _id: ObjectId('726a81ce9a8cd1920741e259'),
    name: 'Екатерина Романовна Дашкова',
    phone: '5824587',
    email: 'erd@mail.ru',
    birthday: '01.01.1991',
    login: 'kati17',
    address: { city: 'СПб', street: 'Дворцовая набережная', building: '38' },
    update_time: ISODate('2024-05-24T10:00:13Z'),
  },
]);

db.restaurants.insertMany([
  {
    _id: ObjectId('7276e8cd0cf48b4cded00001'),
    name: 'Булочная №13',
    phone: '5444485',
    email: 'bun@mail.ru',
    founding_day: '30.04.2014',
    address: 'СПб, Невский пр, 13',
    menu: [
      { _id: ObjectId('7276e8cd0cf48b4cded0087c'), name: 'ОВОЩИ ПО-МЕКСИКАНСКИ', price: 60, dish_category: 'Закуски' },
      { _id: ObjectId('7276e8cd0cf48b4cded0087d'), name: 'КУРИЦА', price: 60, dish_category: 'Закуски' },
      { _id: ObjectId('7276e8cd0cf48b4cded0087e'), name: 'РОЛЛ', price: 120, dish_category: 'Закуски' },
    ],
    update_time: ISODate('2024-05-24T10:00:12Z'),
  },
  {
    _id: ObjectId('7276e8cd0cf48b4cded00002'),
    name: 'Отличная курочка',
    phone: '5444486',
    email: 'hen@mail.ru',
    founding_day: '30.04.2014',
    address: 'СПб, Литейный пр, 5',
    menu: [
      { _id: ObjectId('7276e8cd0cf48b4cded0087f'), name: 'КУРИЦА', price: 70, dish_category: 'Горячее' },
    ],
    update_time: ISODate('2024-05-24T10:00:12Z'),
  },
]);

db.orders.insertMany([
  {
    restaurant_id: 1,
    order_id: 11,
    order_date: ISODate('2026-03-14T13:37:27Z'),
    client_id: 1,
    ordered_dish: [
      { dish_id: 1, name: 'ОВОЩИ ПО-МЕКСИКАНСКИ', price: 60, quantity: 1 },
      { dish_id: 3, name: 'РОЛЛ', price: 120, quantity: 1 },
    ],
    payed_by_bonuses: 0,
    cost: 180,
    payment: 180,
    bonus_for_visit: 2,
    final_status: 'closed',
    update_time: ISODate('2026-03-14T14:00:00Z'),
  },
  {
    restaurant_id: 2,
    order_id: 12,
    order_date: ISODate('2026-03-15T18:10:00Z'),
    client_id: 2,
    ordered_dish: [
      { dish_id: 2, name: 'КУРИЦА', price: 70, quantity: 2 },
    ],
    payed_by_bonuses: 40,
    cost: 140,
    payment: 100,
    bonus_for_visit: 1,
    final_status: 'closed',
    update_time: ISODate('2026-03-15T18:30:00Z'),
  },
]);
