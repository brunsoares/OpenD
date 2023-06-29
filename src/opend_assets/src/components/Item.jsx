import React, { useEffect, useState } from "react";
import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory } from "../../../declarations/nft";
import { idlFactory as tokenIdlFactory } from "../../../declarations/token";
import Button from "./Button";
import { opend } from "../../../declarations/opend";
import CURRENT_USER_ID from "../index";
import PriceLabel from "./PriceLabel";

function Item(props) {

  const [name, setName] = useState();
  const [owner, setOwner] = useState();
  const [image, setImage] = useState();
  const [button, setButton] = useState();
  const [inputPrice, setInputPrice] = useState();
  const [loaderHidden, setLoaderHidden] = useState(true);
  const [blur, setBlur] = useState();
  const [listed, setListed] = useState();
  const [priceLabel, setPriceLabel] = useState();
  const [shouldDisplay, setShouldDisplay] = useState(true);

  const id = props.id;
  const localhost = "http://localhost:8080/";
  const agent = new HttpAgent({host: localhost});
  agent.fetchRootKey(); // Only local development

  let price;
  let NFTActor;

  async function loadNFT(){
    NFTActor = await Actor.createActor(idlFactory, {
      agent,
      canisterId: id 
    });

    const nftName = await NFTActor.getName();
    const nftOwner = await NFTActor.getOwner();
    const nftImageData = await NFTActor.getImage();
    const nftImageContent = new Uint8Array(nftImageData);
    const nftImageUrl = URL.createObjectURL(new Blob([nftImageContent.buffer]), {type: "image/png"});
    
    setName(nftName);
    setOwner(nftOwner.toString());
    setImage(nftImageUrl);

    if(props.role == "collection"){
      const NFTListed = await opend.isListed(id);
      if(NFTListed){
        setOwner("OpenD");
        setListed("Listed");
        setBlur({filter: "blur(6px)"});
      } else {
        setButton(<Button handleClick={handleSell} text={"Sell"}/>);
      }
    } else if (props.role == "discover"){
      const originalOwner = await opend.getOriginalOwner(id);
      if(originalOwner.toString() != CURRENT_USER_ID.toString()){
        setButton(<Button handleClick={handleBuy} text={"Buy"}/>);
      }
      
      const sellPrice = await opend.getSellPrice(id);
      console.log(sellPrice)
      setPriceLabel(<PriceLabel price={sellPrice.toString()}/>)
    }
  }

  useEffect(() => { loadNFT(); }, []);

  async function handleBuy(){
    setLoaderHidden(false);
    const tokenActor = await Actor.createActor(tokenIdlFactory, {
      agent,
      canisterId: Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai"),
    });

    const sellerId = await opend.getOriginalOwner(id);
    const sellPrice = await opend.getSellPrice(id);

    const result = await tokenActor.transfer(sellerId, sellPrice);
    if(result == "Success"){
      const resultTransfer = await opend.completePurchase(id, sellerId, CURRENT_USER_ID);
      console.log("purchase: "+resultTransfer);
      setLoaderHidden(true);
      setShouldDisplay(false);
    }

  }

  function handleSell(){
    setInputPrice(
      <input
        placeholder="Price in BSToken"
        type="number"
        className="price-input"
        value={price}
        onChange={(e) => price = e.target.value}
      />
    );
    setButton(<Button handleClick={confirmSell} text={"Confirm"}/>);
  }

  async function confirmSell(){
    setLoaderHidden(false);
    setBlur({filter: "blur(6px)"})
    const resultListing = await opend.listItem(id, Number(price));
    console.log("listing -> "+resultListing);
    if(resultListing == "Success!"){
      const canisterID = await opend.getOpendCanisterID();
      const resultTransfer = await NFTActor.transferOwnership(canisterID);  
      console.log("transfer -> "+resultTransfer);    
      if(resultTransfer == "Success!"){  
        setLoaderHidden(true);
        setButton();
        setInputPrice();
        setOwner("OpenD");
        setListed("Listed");
      }
    }
  }

  return (
    <div style={{display: shouldDisplay ? "inline" : "none"}} className="disGrid-item">
      <div className="disPaper-root disCard-root makeStyles-root-17 disPaper-elevation1 disPaper-rounded">
        <img
          className="disCardMedia-root makeStyles-image-19 disCardMedia-media disCardMedia-img"
          src={image} 
          style={blur}/>
        <div hidden={loaderHidden} className="lds-ellipsis">
          <div></div>
          <div></div>
          <div></div>
          <div></div>
        </div>
        <div className="disCardContent-root">
          {priceLabel}
          <h2 className="disTypography-root makeStyles-bodyText-24 disTypography-h5 disTypography-gutterBottom">
            {name}<span className="purple-text"> {listed}</span>
          </h2>
          <p className="disTypography-root makeStyles-bodyText-24 disTypography-body2 disTypography-colorTextSecondary">
            Owner: {owner}
          </p>
          {inputPrice}
          {button}
        </div>
      </div>
    </div>
  );
}

export default Item;
