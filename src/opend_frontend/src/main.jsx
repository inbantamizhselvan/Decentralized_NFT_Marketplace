import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './components/App';
import { Principal } from "@dfinity/principal";
import * as dotenv from "dotenv";

dotenv.config();


const CURRENT_USER_ID = Principal.fromText(process.env.USER_ID);
export default CURRENT_USER_ID;

const init = async () => {
  ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  );
  
};

init();
