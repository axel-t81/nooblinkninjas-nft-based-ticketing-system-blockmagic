import "./globals.css";
import Web3StateProvider from './context/Web3StateProvider'

export default function RootLayout({ children }) {
 
  return (    
    <html lang="en">
      <body>
          <Web3StateProvider>
              {children}           
          </Web3StateProvider>
      </body>      
    </html>
  );
}
