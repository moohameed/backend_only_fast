import { Router } from 'express';
import * as notification from '../Controller/NotificationController.js';
import { verifyToken } from '../Middleware/ValidateToken.js';
const router = Router();

router.put('/send-notification', verifyToken, notification.sendNotification );
router.post('/send-notifications', verifyToken, notification.sendNotifications );

export default router;