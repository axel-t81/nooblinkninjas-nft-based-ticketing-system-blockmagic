//lg:py-56
'use client';
import { ethers } from "ethers";
import {useWeb3Context} from './context/useWeb3Context';

export default function Home() {
  const {handleWallet, web3State} = useWeb3Context();
  const {selectedAccount, contractInstance} = web3State;
  let backgroundImageUrl = window.location.origin +"/images/background.jpg";

  let buyTicket = async(e)=>{

    e.preventDefault();
    try{

     await contractInstance.safeMint(selectedAccount);
      //let convertedPrice = await contractInstance.convertUSDToMatic();
     // if (convertedPrice != null){
    //     let convertedPrice = await contractInstance.convertUSDToMatic();
    //     console.log(convertedPrice.toString());
    //     const amountToSend = ethers.parseUnits("0.1");
    //     const options = { value: amountToSend };
    //     const transaction = await contractInstance.confirmTransaction(options);
    //     //await transaction.wait();
    //     console.log(transaction);
    //  console.log("Transaction complete:", transaction.hash);
   //   }
      
    } catch(error){
      console.error(error);
    }
  }

  return (
    <>
      <header>
              <nav className="bg-blue">
                <div className="max-w-screen-xl flex flex-wrap items-center justify-between mx-auto p-4">
                  <a className="flex items-center space-x-3 rtl:space-x-reverse">
                      <img src={`${window.location.origin}/images/football.png`} className="h-8" alt="TicketVerse Logo" />
                      <span className="self-center text-2xl font-semibold whitespace-nowrap header-text">Ticket Verse</span>
                  </a>
                  <div className="hidden w-full md:block md:w-auto" id="navbar-default">
                   <div 
                    className="text-lg font-normal text-gray-300 header-text">{!selectedAccount? "Please connect to the Wallet": selectedAccount}</div>                          
                  </div>
                </div>
              </nav>
      </header>
      <section className="bg-center bg-no-repeat bg-gray-700 bg-blend-multiply min-h-screen"
          style={{backgroundImage: "url(" + backgroundImageUrl + ")" }}>
        <div className="px-4 mx-auto max-w-screen-xl text-center py-24 ">
            <div className="landing-box-background py-5 bg-opacity-10">
              <h3 className="mb-4 text-4xl font-extrabold tracking-tight leading-none text-color-white ">Manchester City v Manchester United Tickets</h3>
              <p className="mb-8 text-lg font-normal text-gray-300 header-text">Wembley Stadium, London, United Kingdom</p>
              <h3 className="mb-4 text-xl font-bold tracking-tight leading-none text-color-white ">Saturday, 25 May 2024 15:00</h3>
              <p className="mb-4 text-lg font-normal text-gray-300 header-text"> From 20.00 USD</p>
              <div className="flex space-y-4 flex-row justify-center">
                {
                  !selectedAccount ? (<a href="#" className="inline-flex justify-center hover:text-gray-900 items-center py-3 px-5 sm:ms-4 text-base 
                  font-medium text-center rounded-lg border border-red hover:bg-gray-100 focus:ring-4 focus:ring-gray-400"
                  onClick={handleWallet}>
                      Connect Wallet
                  </a> ):(<a href="#" className="inline-flex justify-center hover:text-gray-900 items-center py-3 px-5 sm:ms-4 text-base 
                  font-medium text-center rounded-lg border border-red hover:bg-gray-100 focus:ring-4 focus:ring-gray-400"
                  onClick={buyTicket}>
                      Buy Ticket
                  </a>)
                }
             </div>
            </div>
        </div>
       </section>
      <footer className="bg-blue">
        <div className="mx-auto w-full max-w-screen-xl p-4 py-8">
          <div className="flex items-center justify-between">
              <span className="text-sm text-center text-color-white">Copyright © 2024 NoobLink Ninjas. All Rights Reserved.
              </span>
          </div>
        </div>
      </footer>
</>
  );
}
