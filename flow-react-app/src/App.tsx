import React, { useState, useEffect } from 'react';
import { flowService } from './services/flow';
import './App.css';

function App() {
  const [user, setUser] = useState<any>(null);
  const [imageUrl, setImageUrl] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    // Check if user is already authenticated
    flowService.getCurrentUser().then(user => {
      if (user.loggedIn) {
        setUser(user);
      }
    });
  }, []);

  const handleAuthenticate = async () => {
    try {
      setLoading(true);
      setError('');
      await flowService.authenticate();
      const currentUser = await flowService.getCurrentUser();
      setUser(currentUser);
    } catch (err) {
      setError('Authentication failed');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    try {
      setLoading(true);
      setError('');
      await flowService.logout();
      setUser(null);
    } catch (err) {
      setError('Logout failed');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleGetImage = async () => {
    try {
      setLoading(true);
      setError('');
      const result = await flowService.getImage();
      setImageUrl(result);
    } catch (err) {
      setError('Failed to get image');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Flow Blockchain Demo</h1>
        
        {error && <div className="error">{error}</div>}
        
        {!user ? (
          <button 
            onClick={handleAuthenticate} 
            disabled={loading}
            className="auth-button"
          >
            {loading ? 'Loading...' : 'Connect Wallet'}
          </button>
        ) : (
          <div className="user-section">
            <p>Connected as: {user.addr}</p>
            <button 
              onClick={handleLogout} 
              disabled={loading}
              className="auth-button"
            >
              {loading ? 'Loading...' : 'Disconnect'}
            </button>
          </div>
        )}

        <div className="image-section">
          <button 
            onClick={handleGetImage} 
            disabled={loading}
            className="action-button"
          >
            {loading ? 'Loading...' : 'Get Image'}
          </button>
          {imageUrl && (
            <div className="image-container">
              <img 
                src={"data:image/png;base64,".concat(imageUrl)} 
                alt="From Flow Blockchain" 
                className="blockchain-image"
              /> Hello
            </div>
          )}
        </div>
      </header>
    </div>
  );
}

export default App;
