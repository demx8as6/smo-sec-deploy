import React, { useEffect, useState } from 'react';
import { List, ListItem, ListItemText, CircularProgress } from '@mui/material';

interface ServiceLink {
  name: string;
  url: string;
}

const LinkList: React.FC = () => {
  const [links, setLinks] = useState<ServiceLink[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/services')
      .then(res => res.json())
      .then(data => setLinks(data))
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <CircularProgress />;

  return (
    <List>
      {links.map((link, idx) => (
        <ListItem button component="a" href={link.url} key={idx}>
          <ListItemText primary={link.name} />
        </ListItem>
      ))}
    </List>
  );
};

export default LinkList;
