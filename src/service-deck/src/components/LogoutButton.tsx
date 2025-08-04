import React from 'react';
import { Button } from '@mui/material';

const httpDomain = window.location.host.split(".").slice(1).join(".");

const deleteCookie = (name: string, path: string = '/', domain?: string) => {
  let cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=${path};`;
  if (domain) {
    process.env.REACT_APP_HTTP_DOMAIN
    cookie += ` domain=${domain};`;
  }
  document.cookie = cookie;
};

const LogoutButton: React.FC = () => {
  const handleLogout = () => {
    // Try removing the _oauth2-proxy cookie set by oauth2-proxy (if accessible)
    deleteCookie('_oauth2-proxy', '/', `.${httpDomain}`);

    // Redirect to keycloak logout with post-logout redirect
    window.location.href = `https://keycloak.${httpDomain}/realms/o-ran-sc/protocol/openid-connect/logout?redirect_uri=https://oauth2-proxy.${httpDomain}/oauth2/sign_out`;
  };

  return (
    <Button
      variant="outlined"
      color="primary"
      onClick={handleLogout}
      style={{ marginBottom: '1rem' }}
    >
      Logout
    </Button>
  );
};

export default LogoutButton;
