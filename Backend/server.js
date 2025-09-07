const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

let users = [
  { id: 1, username:'End User', role: 'End User' },
  { id: 2, username: 'Receiver', role: 'Receiver' },
];

let requests = [];
let requestIdCounter = 1;
let itemIdCounter = 1;

const handlePartialFulfillment = (originalRequest, confirmedItems, unconfirmedItems) => {
  if (unconfirmedItems.length > 0) {
    originalRequest.status = 'Partially Fulfilled';
      
    const newRequest = {
      id: requestIdCounter++,
      userId: originalRequest.userId,
      items: unconfirmedItems.map(item => ({ ...item, status: 'Pending' })),
      status: 'Pending',
      timestamp: new Date().toISOString()
    };
    requests.push(newRequest);
    console.log(`Partial fulfillment: New request #${newRequest.id} created for unconfirmed items from request #${originalRequest.id}`);
  } else {
    originalRequest.status = 'Confirmed';
  }
};

// Login Endpoint
app.post('/login', (req, res) => {
  const { username } = req.body;
  const user = users.find(u => u.username === username);
  if (user) {
    res.json({ id: user.id, username: user.username, role: user.role });
  } else {
    res.status(401).json({ message: 'Invalid username' });
  }
});

// Create Request Endpoint 
app.post('/requests', (req, res) => {
  const { userId, items } = req.body;
  const newRequest = {
    id: requestIdCounter++,
    userId,
    items: items.map(name => ({ id: itemIdCounter++, name, status: 'Pending' })),
    status: 'Pending',
    timestamp: new Date().toISOString()
  };
  requests.push(newRequest);
  res.status(201).json(newRequest);
});

// Fetch Requests Endpoint 
app.get('/requests', (req, res) => {
  const { role, userId } = req.query;
  let filteredRequests = requests;

  if (role === 'End User') {
    filteredRequests = filteredRequests.filter(req => req.userId.toString() === userId);
  } else if (role === 'Receiver') {
    filteredRequests = filteredRequests.filter(req => req.status === 'Pending' || req.status === 'Partially Fulfilled');
  }

  res.json(filteredRequests);
});

// Update Confirmation Status Endpoint 
app.patch('/requests/:id', (req, res) => {
  const { id } = req.params;
  const { confirmations } = req.body;

  const requestIndex = requests.findIndex(r => r.id.toString() === id);
  if (requestIndex === -1) {
    return res.status(404).json({ message: 'Request not found' });
  }

  const originalRequest = requests[requestIndex];
  const confirmedItems = [];
  const unconfirmedItems = [];

  // Update item statuses based on receiver feedback
  originalRequest.items = originalRequest.items.map(item => {
    const confirmation = confirmations.find(c => c.id === item.id);
    if (confirmation) {
      const updatedItem = { ...item, status: confirmation.status };
      if (confirmation.status === 'Available') {
        confirmedItems.push(updatedItem);
      } else {
        unconfirmedItems.push(updatedItem);
      }
      return updatedItem;
    }
    return item;
  });

  // Handle partial fulfillment logic
  handlePartialFulfillment(originalRequest, confirmedItems, unconfirmedItems);

  res.json(originalRequest);
});

app.listen(port, () => {
  console.log(`Mock backend listening at http://localhost:${port}`);
});
