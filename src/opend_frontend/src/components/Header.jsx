import React, { useEffect, useState } from "react";
import logo from "../assets/logo.png";
import homeImage from "../assets/home-img.png";
import Minter from "./Minter";
import Gallery from "./Gallery";
import { BrowserRouter, Link, Route, Routes } from "react-router-dom";
import { opend_backend } from "../../../declarations/opend_backend";
import CURRENT_USER_ID from "../main";

function Header() {
  const [userOwnedGallery, setOwnedGallery] = useState(null);
  const [listingGallery, setListingGallery] = useState(null);

  async function getNFTs() {
    const userNFTIds = await opend_backend.getOwnedNFTs(CURRENT_USER_ID);
    console.log(userNFTIds);
    setOwnedGallery(<Gallery title="MY NFTs" ids={userNFTIds} role="collection"/>);
    const listedNFTIds = await opend_backend.getListedNFTs();
    console.log(listedNFTIds);
    setListingGallery(<Gallery title="Discover" ids={listedNFTIds} role="discover"/>);
  };

  useEffect(() => {
    getNFTs();
  }, []);

  return (
    <BrowserRouter>
      <div className="app-root-1">
        <header className="Paper-root AppBar-root AppBar-positionStatic AppBar-colorPrimary Paper-elevation4">
          <div className="Toolbar-root Toolbar-regular header-appBar-13 Toolbar-gutters">
            <div className="header-left-4"></div>
            <img className="header-logo-11" src={logo} alt="logo" />
            <div className="header-vertical-9"></div>
            <Link to="/">
              <h5 className="Typography-root header-logo-text">OpenDin</h5>
            </Link>
            <div className="header-empty-6"></div>
            <div className="header-space-8"></div>
            <button className="ButtonBase-root Button-root Button-text header-navButtons-3">
              <Link to="/discover" reloadDocument> Discover </Link>
            </button>
            <button className="ButtonBase-root Button-root Button-text header-navButtons-3">
              <Link to="/minter"> Minter </Link>
            </button>
            <button className="ButtonBase-root Button-root Button-text header-navButtons-3">
              <Link to="/collection" reloadDocument> My NFTs </Link>
            </button>
          </div>
        </header>
      </div>
      <Routes>
        <Route
          exact
          path="/"
          element={
            <>
              <img className="bottom-space" src={homeImage} alt="Home" />
            </>
          }
        />
        <Route path="/discover" element={listingGallery}/>
        <Route path="/minter" element={<Minter />} />
        <Route path="/collection" element={userOwnedGallery} />
      </Routes>
    </BrowserRouter>
  );
}

export default Header;
