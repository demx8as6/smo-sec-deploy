import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Container,
  CssBaseline,
  Box
} from '@mui/material';
import { ThemeProvider } from '@mui/material/styles';
import theme from './theme/theme';
import LinkList from './components/LinkList';
import LogoutButton from './components/LogoutButton';

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />

      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div">
            SMO OAM ServiceDeck
          </Typography>
        </Toolbar>
      </AppBar>

      <Container sx={{ mt: 4, mb: 4 }}>
        <Typography variant="h4" gutterBottom>ServiceDeck</Typography>
        <Typography variant="subtitle1" gutterBottom>One interface. Every service.</Typography>
        <LogoutButton />
        <LinkList />
      </Container>

      <Box component="footer" sx={{ p: 2, textAlign: 'center', bgcolor: 'background.paper' }}>
        <Typography variant="body2" color="textSecondary">
          &copy; {new Date().getFullYear()} highstreet technologies GmbH
        </Typography>
      </Box>
    </ThemeProvider>
  );
}

export default App;
