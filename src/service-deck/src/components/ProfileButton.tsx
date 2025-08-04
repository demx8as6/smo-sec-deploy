import React from 'react';
import { Button } from '@mui/material';

const httpDomain = window.location.host.split(".").slice(1).join(".");

const ProfileButton: React.FC = () => {
  const handleLogout = () => {
    // Redirect to keycloak logout with post-logout redirect
    window.location.href = `https://keycloak.${httpDomain}/realms/o-ran-sc/account/`;
  };

  return (
    <Button
      variant="outlined"
      color="primary"
      onClick={handleLogout}
      style={{ marginBottom: '1rem' }}
    >
      Profile
    </Button>
  );
};

export default ProfileButton;
