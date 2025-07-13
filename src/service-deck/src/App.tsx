import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Container,
  CssBaseline,
  Box,
  Grid,
  Paper
} from '@mui/material';
import { ThemeProvider } from '@mui/material/styles';
import theme from './theme/theme';
import LinkList from './components/LinkList';
import LogoutButton from './components/LogoutButton';

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />

      <AppBar
        position="static"
        sx={{
          background: 'linear-gradient(to right, white 0%, white 20%, #2CA8A4 100%)',
          color: '#000',
        }}
      >
        <Toolbar>
          <img src="/service-deck-logo.svg" alt="ServiceDeck Logo" style={{ height: 40, marginRight: 16 }} />
        </Toolbar>
      </AppBar>

      <Container sx={{ mt: 4, mb: 4 }}>
        <Typography gutterBottom>The ServiceDeck offers all SMO OAM related services in one interface.</Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} md={9}>
            <Paper elevation={2} sx={{ p: 2 }}>
              <LinkList />
            </Paper>
          </Grid>
          <Grid item xs={12} md={3}>
            <Paper elevation={2} sx={{ p: 2 }}>
              <Typography variant="subtitle2" gutterBottom>
                <LogoutButton />
              </Typography>
              <Typography variant="body2">Coming soon...</Typography>
            </Paper>
          </Grid>
        </Grid>
      </Container>

      <Box component="footer" sx={{
        p: 2,
        textAlign: 'left',
        background: 'linear-gradient(to right, white 0%, white 20%, #2CA8A4 100%)',
        }}>
        <Typography variant="body2" color="textSecondary">
          &copy; {new Date().getFullYear()} smo.o-ran-sc.org
        </Typography>
      </Box>
    </ThemeProvider>
  );
}

export default App;
