import React, { useEffect, useState } from 'react';
import { Box, Typography, CircularProgress } from '@mui/material';

interface UserInfoResponse {
  user: string;
  groups: string;
  email: string;
  displayGroups?: string;
}

const UserInfo: React.FC = () => {
  const [userInfo, setUserInfo] = useState<UserInfoResponse | null>(null);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    fetch('/api/userinfo')
      .then((res) => {
        if (!res.ok) {
          throw new Error('Failed to fetch user info');
        }
        return res.json();
      })
      .then((data: UserInfoResponse) => {
        setUserInfo(data);
      })
      .catch((error) => {
        console.error('Error fetching user info:', error);
        setUserInfo(null);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <Box sx={{ px: 2, py: 1 }}>
        <CircularProgress size={16} />
      </Box>
    );
  }

  if (!userInfo) {
    return (
      <Box sx={{ px: 2, py: 1 }}>
        <Typography variant="body2" color="error">
          Unable to load user information
        </Typography>
      </Box>
    );
  }

  const groups = userInfo.groups.split(',').map(g => g.trim());
  const allowedGroups = new Set(["Administration", "Operation", "Supervision"]);
  userInfo.displayGroups = groups.filter(item => allowedGroups.has(item)).join(', ');
  return (
    <Box sx={{ px: 2, py: 1 }}>
      <Typography variant="body2">
        Logged in as <strong>{userInfo.email}</strong>
      </Typography>
      <Typography variant="body2" color="text.secondary">
        Groups: {userInfo.displayGroups}
      </Typography>
    </Box>
  );
};

export default UserInfo;
