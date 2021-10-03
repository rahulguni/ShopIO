# ShopIO
## Installation Guide
*Client-Side*<br/><br/>
First you have to make sure you have cocoapods installed on your mac. All you have to do is run a “pod install” command on the folder terminal, and open the workspace from XCode.
Note: If you have the latest version of XCode, the program may not compile because of some changes in Swift 5. Please replace ImagePicker in the podfile to the latest version if you are using the latest release of XCode.
To connect to your local-host, you will have to pass the server URL in the app’s AppDelegate.swift file.<br/><br/>
*Server-Side*<br/><br/>
Install all the third-party dependencies with “npm install” and run “npm start”. Before running these programs however, you need to make sure you have an existing PostgreSQL database named “ecommerce” on your machine. You can set this up from “database.txt” file included in the sever directory which has the database schema. Please make sure to add foreign keys and indexes as advised in the schema to make sure the server runs smoothly. You can also keep a track of the data using the server’s dashboard.<br/>
Alternatively, you can also do this the longer way by creating an empty PostgreSQL database named “ecommerce” and adding the tables and columns from Parse dashboard which can be found on route ‘/dashboard’. Then you can set up indexes and foreign keys looking at the database schema provided.<br/><br/>
## Summary
In short, here are all the on-surface features of this ecommerce app:<br/>
Begin by signing up. This is required to open a shop as well as purchase items.<br/><br/>
*User Side*<br/>
- Discover Shops around you based on your location. Filter radius can be set on the Discover View.
- Search by items or among your local shops.
- Keep a list of your favorite shops.
- Review your purchased items. 
- Pickup and Delivery option for order.
- Chat with Shop.<br/><br/>

*Shop Side*<br/>
- Open and customize your shop.
- Manage Your Inventory, Update Products, Orders and Requests.
- Add and Manage Products with images.
