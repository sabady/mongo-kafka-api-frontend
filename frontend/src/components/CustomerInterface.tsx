import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  Button,
  Grid,
  Alert,
  CircularProgress,
  Chip,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Divider,
  Paper
} from '@mui/material';
import {
  Add as AddIcon,
  ShoppingCart as ShoppingCartIcon,
  Person as PersonIcon,
  CheckCircle as CheckCircleIcon,
  Error as ErrorIcon,
  Refresh as RefreshIcon
} from '@mui/icons-material';
import { v4 as uuidv4 } from 'uuid';

import KafkaProducerService from '../services/kafkaProducer';
import ApiService from '../services/apiService';
import { generateRandomProductWithVariations } from '../utils/randomProducts';
import { Product, Customer, RandomProduct } from '../types';

const CustomerInterface: React.FC = () => {
  const [customerName, setCustomerName] = useState<string>('');
  const [kafkaProducer] = useState<KafkaProducerService>(new KafkaProducerService());
  const [apiService] = useState<ApiService>(new ApiService());
  const [isKafkaConnected, setIsKafkaConnected] = useState<boolean>(false);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error' | 'info'; text: string } | null>(null);
  const [boughtItems, setBoughtItems] = useState<RandomProduct[]>([]);
  const [productsFromDB, setProductsFromDB] = useState<Product[]>([]);
  const [isLoadingProducts, setIsLoadingProducts] = useState<boolean>(false);

  useEffect(() => {
    initializeKafka();
    return () => {
      kafkaProducer.disconnect();
    };
  }, []);

  const initializeKafka = async () => {
    try {
      await kafkaProducer.connect();
      setIsKafkaConnected(true);
      showMessage('success', 'Connected to Kafka successfully!');
    } catch (error) {
      console.error('Failed to connect to Kafka:', error);
      setIsKafkaConnected(false);
      showMessage('error', 'Failed to connect to Kafka. Please check your connection.');
    }
  };

  const showMessage = (type: 'success' | 'error' | 'info', text: string) => {
    setMessage({ type, text });
    setTimeout(() => setMessage(null), 5000);
  };

  const handleAddRandomItem = async () => {
    if (!customerName.trim()) {
      showMessage('error', 'Please enter your name first!');
      return;
    }

    if (!isKafkaConnected) {
      showMessage('error', 'Kafka is not connected. Please wait and try again.');
      return;
    }

    setIsLoading(true);
    try {
      const randomProduct = generateRandomProductWithVariations();
      const productId = uuidv4();
      
      // Add to local bought items list
      const boughtItem = { ...randomProduct, id: productId };
      setBoughtItems(prev => [...prev, boughtItem]);

      // Publish to Kafka
      await kafkaProducer.publishRandomProductAdded(
        { ...boughtItem, correlationId: uuidv4() },
        customerName
      );

      // Also publish as a product creation event
      await kafkaProducer.publishProductCreated({
        ...boughtItem,
        correlationId: uuidv4()
      });

      // Publish audit log
      await kafkaProducer.publishAuditLog({
        action: 'random_product_added',
        resource: 'product',
        customerName,
        productName: randomProduct.name,
        correlationId: uuidv4()
      });

      showMessage('success', `Added "${randomProduct.name}" to your bought items!`);
    } catch (error) {
      console.error('Error adding random item:', error);
      showMessage('error', 'Failed to add random item. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleGetProductsFromDB = async () => {
    if (!customerName.trim()) {
      showMessage('error', 'Please enter your name first!');
      return;
    }

    setIsLoadingProducts(true);
    try {
      // Publish API request event
      await kafkaProducer.publishApiRequest({
        method: 'GET',
        path: '/api/products',
        customerName,
        correlationId: uuidv4()
      });

      const response = await apiService.getProducts();
      
      if (response.success && response.data) {
        setProductsFromDB(response.data);
        
        // Publish API response event
        await kafkaProducer.publishApiResponse({
          method: 'GET',
          path: '/api/products',
          statusCode: 200,
          customerName,
          correlationId: uuidv4()
        });

        // Publish audit log
        await kafkaProducer.publishAuditLog({
          action: 'products_retrieved',
          resource: 'products',
          customerName,
          count: response.data.length,
          correlationId: uuidv4()
        });

        showMessage('success', `Retrieved ${response.data.length} products from database!`);
      } else {
        throw new Error(response.message || 'Failed to retrieve products');
      }
    } catch (error: any) {
      console.error('Error getting products from DB:', error);
      
      // Publish API error event
      await kafkaProducer.publishApiError({
        method: 'GET',
        path: '/api/products',
        statusCode: 500,
        error: error.message,
        customerName,
        correlationId: uuidv4()
      });

      showMessage('error', `Failed to get products: ${error.message}`);
    } finally {
      setIsLoadingProducts(false);
    }
  };

  const handleClearBoughtItems = () => {
    setBoughtItems([]);
    showMessage('info', 'Cleared bought items list');
  };

  const handleClearProductsFromDB = () => {
    setProductsFromDB([]);
    showMessage('info', 'Cleared products from database list');
  };

  return (
    <Box sx={{ maxWidth: 1200, margin: '0 auto', padding: 3 }}>
      <Typography variant="h3" component="h1" gutterBottom align="center" color="primary">
        Customer Frontend - Kafka Producer
      </Typography>

      {/* Status Card */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item>
              <Typography variant="h6">System Status:</Typography>
            </Grid>
            <Grid item>
              <Chip
                icon={isKafkaConnected ? <CheckCircleIcon /> : <ErrorIcon />}
                label={isKafkaConnected ? 'Kafka Connected' : 'Kafka Disconnected'}
                color={isKafkaConnected ? 'success' : 'error'}
                variant="outlined"
              />
            </Grid>
            <Grid item>
              <Button
                variant="outlined"
                startIcon={<RefreshIcon />}
                onClick={initializeKafka}
                disabled={isKafkaConnected}
              >
                Reconnect Kafka
              </Button>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Customer Name Input */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h5" gutterBottom>
            <PersonIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
            Customer Information
          </Typography>
          <TextField
            fullWidth
            label="Enter your name"
            value={customerName}
            onChange={(e) => setCustomerName(e.target.value)}
            placeholder="Type your name here..."
            variant="outlined"
            sx={{ mt: 2 }}
          />
        </CardContent>
      </Card>

      {/* Action Buttons */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h5" gutterBottom>
            <ShoppingCartIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
            Actions
          </Typography>
          <Grid container spacing={2} sx={{ mt: 2 }}>
            <Grid item xs={12} sm={6}>
              <Button
                fullWidth
                variant="contained"
                color="primary"
                size="large"
                startIcon={isLoading ? <CircularProgress size={20} /> : <AddIcon />}
                onClick={handleAddRandomItem}
                disabled={isLoading || !isKafkaConnected}
              >
                {isLoading ? 'Adding...' : 'Add Random Item to Bought List'}
              </Button>
            </Grid>
            <Grid item xs={12} sm={6}>
              <Button
                fullWidth
                variant="contained"
                color="secondary"
                size="large"
                startIcon={isLoadingProducts ? <CircularProgress size={20} /> : <ShoppingCartIcon />}
                onClick={handleGetProductsFromDB}
                disabled={isLoadingProducts}
              >
                {isLoadingProducts ? 'Loading...' : 'Get Products from MongoDB'}
              </Button>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Message Display */}
      {message && (
        <Alert severity={message.type} sx={{ mb: 3 }}>
          {message.text}
        </Alert>
      )}

      {/* Bought Items List */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
            <Typography variant="h5">
              Bought Items ({boughtItems.length})
            </Typography>
            {boughtItems.length > 0 && (
              <Button
                variant="outlined"
                color="error"
                onClick={handleClearBoughtItems}
              >
                Clear List
              </Button>
            )}
          </Box>
          {boughtItems.length === 0 ? (
            <Paper sx={{ p: 3, textAlign: 'center', bgcolor: 'grey.50' }}>
              <Typography color="text.secondary">
                No items added yet. Click "Add Random Item" to start!
              </Typography>
            </Paper>
          ) : (
            <List>
              {boughtItems.map((item, index) => (
                <React.Fragment key={item.id}>
                  <ListItem>
                    <ListItemText
                      primary={item.name}
                      secondary={
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            {item.description}
                          </Typography>
                          <Box display="flex" gap={1} mt={1}>
                            <Chip label={item.category} size="small" color="primary" />
                            <Chip label={`$${item.price}`} size="small" color="secondary" />
                            <Chip label={`Qty: ${item.quantity}`} size="small" />
                          </Box>
                        </Box>
                      }
                    />
                  </ListItem>
                  {index < boughtItems.length - 1 && <Divider />}
                </React.Fragment>
              ))}
            </List>
          )}
        </CardContent>
      </Card>

      {/* Products from Database */}
      <Card>
        <CardContent>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
            <Typography variant="h5">
              Products from MongoDB ({productsFromDB.length})
            </Typography>
            {productsFromDB.length > 0 && (
              <Button
                variant="outlined"
                color="error"
                onClick={handleClearProductsFromDB}
              >
                Clear List
              </Button>
            )}
          </Box>
          {productsFromDB.length === 0 ? (
            <Paper sx={{ p: 3, textAlign: 'center', bgcolor: 'grey.50' }}>
              <Typography color="text.secondary">
                No products loaded yet. Click "Get Products from MongoDB" to load!
              </Typography>
            </Paper>
          ) : (
            <List>
              {productsFromDB.map((product, index) => (
                <React.Fragment key={product.id}>
                  <ListItem>
                    <ListItemText
                      primary={product.name}
                      secondary={
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            {product.description}
                          </Typography>
                          <Box display="flex" gap={1} mt={1}>
                            <Chip label={product.category} size="small" color="primary" />
                            <Chip label={`$${product.price}`} size="small" color="secondary" />
                            <Chip 
                              label={product.inStock ? 'In Stock' : 'Out of Stock'} 
                              size="small" 
                              color={product.inStock ? 'success' : 'error'} 
                            />
                            <Chip label={`Qty: ${product.quantity}`} size="small" />
                          </Box>
                        </Box>
                      }
                    />
                  </ListItem>
                  {index < productsFromDB.length - 1 && <Divider />}
                </React.Fragment>
              ))}
            </List>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};

export default CustomerInterface;
