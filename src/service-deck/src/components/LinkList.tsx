import React, { useEffect, useState } from 'react';
import { List, ListItemButton, ListItemText, CircularProgress } from '@mui/material';

interface ServiceRouter {
  name: string;
  priority: number;
  provider: string;
  rule: string;
  label?: string;
  url?: string;
}

const LinkList: React.FC = () => {
  const [routers, setLinks] = useState<ServiceRouter[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/services')
      .then(res => res.json())
      .then(data => {
        const enriched = data.map((item: ServiceRouter) => ({
          ...item,
          host: item.rule.split("`")[1],
          label: item.rule.split("`")[1].split(".")[0],
          url: `https://oauth2-proxy.smo.o-ran-sc.org/oauth2/start?rd=https://${item.rule.split("`")[1]}`
        }));
        setLinks(enriched);
      })
      .catch(err => console.error(err))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <CircularProgress />;

  return (
    <List>
      {routers.filter(item => item.provider === 'docker')
        .sort((a, b) => (a.priority ?? 0) - (b.priority ?? 0))
        .map((link, idx) => (
          <ListItemButton component="a" href={link.url} key={idx}>
            <ListItemText primary={(link.label ?? link.name).toUpperCase()} />
          </ListItemButton>
        ))}
    </List>
  );
};

export default LinkList;
