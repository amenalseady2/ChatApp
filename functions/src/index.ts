import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { log } from 'util';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
export const sendToDevice = functions.firestore
    .document('conversations/{conversationID}/messages/{msgID}')
    .onWrite(async (snapshot, context) => {
        const msg = snapshot.after.data();
        log(`loggg write ${context.params.conversationID}`);
        if (msg) {
            var id: String = '', senderName: string = '', senderPhoto: string = '', recieverToken: string = '';

            var users: []
            await db.collection('conversations').doc(context.params.conversationID).get().then(
                async snapshot => {
                    log(`loggg update ${snapshot.get('users')}`);
                    users = snapshot.get('users');
                    users.forEach((element: String) => {
                        if (element != msg.sender_id) id = element;
                    });
                }
            );

            log(`loggg update ${id} ${msg.sender_id}`);

            await db.collection('users').doc(`${msg.sender_id}`).get().then(
                async snapshot => {
                    senderName = snapshot.get('name');
                    senderPhoto = snapshot.get('photo_url');
                }
            );

            const recieverSnapshot = db.collection('users').doc(`${id}`).get();
            await recieverSnapshot.then(
                async snapshot => {
                    recieverToken = snapshot.get('token');
                }
            );

            log(`loggg ${recieverToken}`);

            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: `${senderName}`,
                    body: `${msg.content}`,
                },
                data: {
                    icon: `${senderPhoto}`,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK'
                },
            };

            return fcm.sendToDevice(
                recieverToken,
                payload);


        } else {
            return null;
        }
    });

