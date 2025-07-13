import React from 'react';
import { Button } from '@mui/material';

const LogoutButton: React.FC = () => {
  const handleLogout = () => {
    // Add your logout logic (e.g., clear cookies, redirect)
    window.location.href = '/logout';
  };

  return (
    <Button variant="outlined" color="primary" onClick={handleLogout} style={{ marginBottom: '1rem' }}>
      Logout
    </Button>
  );
};

export default LogoutButton;
