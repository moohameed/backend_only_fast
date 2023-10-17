import { response } from 'express';
import pool from '../Database/mysql.js';
import { admin } from '../App.js';


export const sendNotification = (req, res = response ) => {
    
    console.log("sender")

    const {token, msg} = req.body

                // This registration token comes from the client FCM SDKs.
        const registrationToken = token;
        const message = {
        data: {
            body: msg
        },
        };

        // Send a message to the device corresponding to the provided
        // registration token.
        console.log(token)
        admin.messaging().sendToDevice(registrationToken, message)
  .then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
    console.log(response.results[0].error)
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });

  return res.json({
    resp: true,
    msg : 'Successfully sent message',
});


}

export const sendNotifications = (req, res = response ) => {
    
  console.log("senderMulti")

  const {tokens, msg} = req.body

          
      if (!tokens || !msg) {
        return res.status(400).json({ error: 'Invalid request data' });
      }
      for (let i = 0; i < tokens.length; i++) {
        console.log("token; ", tokens[i])
        let message = {
          data: {
              body: msg
          },
          };
          admin.messaging().sendToDevice(tokens[i], message)
          .then((response) => {
            console.log('Successfully sent message:', response);
            console.log(response.results[0].error)
          })
          .catch((error) => {
            console.log('Error sending message:', error);
          });
        
          res.json({
            resp: true,
            msg : 'Successfully sent message',
        });
        
        
      }
}