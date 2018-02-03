//
//  PebbleProtocol.swift
//  Protocl for talking with Pebble watches over BLE. Encoding and the sort.
//
//  Created by Carson Katri on 1/13/18.
//  Copyright © 2018 Carson Katri. All rights reserved.
//

import Foundation
import Bluejay

class PebbleProtocol {
    static let shared = PebbleProtocol()
    
    let prefixLength: UInt8 = 4
    
    func encodeSimpleMessage(endpoint: Endpoint, command: UInt8) -> [Byte] {
        let simpleMessageLength: UInt8 = 1
        var buffer = ByteBuffer(size: Int(prefixLength + simpleMessageLength))
        buffer.append([simpleMessageLength])
        buffer.append([UInt8(endpoint.rawValue)])
        buffer.append([command])
        
        return buffer.values
    }
    
    func encodeReboot() -> [Byte] {
        return encodeSimpleMessage(endpoint: Endpoint.ENDPOINT_RESET, command: 0)
    }
}

/*
public byte[] encodeNotification(NotificationSpec notificationSpec) {
    boolean hasHandle = notificationSpec.id != -1 && notificationSpec.phoneNumber == null;
    int id = notificationSpec.id != -1 ? notificationSpec.id : mRandom.nextInt();
    String title;
    String subtitle = null;
    
    // for SMS that came in though the SMS receiver
    if (notificationSpec.sender != null) {
        title = notificationSpec.sender;
        subtitle = notificationSpec.subject;
    } else {
        title = notificationSpec.title;
    }
    
    Long ts = System.currentTimeMillis();
    if (mFwMajor < 3) {
        ts += (SimpleTimeZone.getDefault().getOffset(ts));
    }
    ts /= 1000;
    
    if (mFwMajor >= 3) {
        // 3.x notification
        return encodeBlobdbNotification(id, (int) (ts & 0xffffffffL), title, subtitle, notificationSpec.body, notificationSpec.sourceName, hasHandle, notificationSpec.type, notificationSpec.cannedReplies);
    } else if (mForceProtocol || notificationSpec.type != NotificationType.GENERIC_EMAIL) {
        // 2.x notification
        return encodeExtensibleNotification(id, (int) (ts & 0xffffffffL), title, subtitle, notificationSpec.body, notificationSpec.sourceName, hasHandle, notificationSpec.cannedReplies);
    } else {
        // 1.x notification on FW 2.X
        String[] parts = {title, notificationSpec.body, ts.toString(), subtitle};
        // be aware that type is at this point always NOTIFICATION_EMAIL
        return encodeMessage(ENDPOINT_NOTIFICATION, NOTIFICATION_EMAIL, 0, parts);
    }
}
*/

struct NotificationType {
    // (colorId, iconId)
    static let Unknown = (UInt8(0), 0)
}


func encodeNotification(title: String, subtitle: String, body: String, id: Int, type: (UInt8, Int)) -> [UInt8] {
    return encodeBlobdbNotification(id: id, timestamp: Int(Date().timeIntervalSince1970), title: title, subtitle: subtitle, body: body, sourceName: "", hasHandle: false, type: type, cannedReplies: [String]())
}

func encodeBlobdbNotification(id: Int, timestamp: Int, title: String, subtitle: String, body: String, sourceName: String, hasHandle: Bool, type: (UInt8, Int) = NotificationType.Unknown, cannedReplies: [String]) -> [UInt8] {
    var notificationPinLength = 46
    var actionLengthMin = 10
    
    var parts: [String] = [title, subtitle, body]
    
    // Calculate the length
    var actionsCount: UInt8!
    var actionsLength: Int!
    var dismissString: String!
    var openString: String! = "Open on phone"
    var muteString: String! = "Mute"
    var replyString: String! = "Reply"
    if sourceName != nil {
        muteString = "\(muteString) " + sourceName
    }
    
    var dismissActionId: UInt8!
    if hasHandle && sourceName != "ALARMCLOCKRECEIVER" {
        actionsCount = 3
        dismissString = "Dismiss"
        dismissActionId = 0x02
        let arrayLengths = Array(dismissString.utf8).count + Array(openString.utf8).count + Array(muteString.utf8).count
        actionsLength = Int((actionLengthMin * Int(actionsCount)) + arrayLengths)
    } else {
        actionsCount = 1
        dismissString = "Dismiss All"
        dismissActionId = 0x03
    }
    
    return [UInt8]()
}

/*
private byte[] encodeBlobdbNotification(int id, int timestamp, String title, String subtitle, String body, String sourceName, boolean hasHandle, NotificationType notificationType, String[] cannedReplies) {
    final short NOTIFICATION_PIN_LENGTH = 46;
    final short ACTION_LENGTH_MIN = 10;
    
    String[] parts = {title, subtitle, body};
    
    if(notificationType == null) {
        notificationType = NotificationType.UNKNOWN;
    }
    
    int icon_id = notificationType.icon;
    byte color_id = notificationType.color;
    
    // Calculate length first
    byte actions_count;
    short actions_length;
    String dismiss_string;
    String open_string = "Open on phone";
    String mute_string = "Mute";
    String reply_string = "Reply";
    if (sourceName != null) {
        mute_string += " " + sourceName;
    }
    
    byte dismiss_action_id;
    if (hasHandle && !"ALARMCLOCKRECEIVER".equals(sourceName)) {
        actions_count = 3;
        dismiss_string = "Dismiss";
        dismiss_action_id = 0x02;
        actions_length = (short) (ACTION_LENGTH_MIN * actions_count + dismiss_string.getBytes().length + open_string.getBytes().length + mute_string.getBytes().length);
    } else {
        actions_count = 1;
        dismiss_string = "Dismiss all";
        dismiss_action_id = 0x03;
        actions_length = (short) (ACTION_LENGTH_MIN * actions_count + dismiss_string.getBytes().length);
    }
    
    int replies_length = -1;
    if (cannedReplies != null && cannedReplies.length > 0) {
        actions_count++;
        for (String reply : cannedReplies) {
            replies_length += reply.getBytes().length + 1;
        }
        actions_length += ACTION_LENGTH_MIN + reply_string.getBytes().length + replies_length + 3; // 3 = attribute id (byte) + length(short)
    }
    
    byte attributes_count = 2; // icon
    short attributes_length = (short) (11 + actions_length);
    if (parts != null) {
        for (String s : parts) {
            if (s == null || s.equals("")) {
                continue;
            }
            attributes_count++;
            attributes_length += (3 + s.getBytes().length);
        }
    }
    
    short pin_length = (short) (NOTIFICATION_PIN_LENGTH + attributes_length);
    
    ByteBuffer buf = ByteBuffer.allocate(pin_length);
    
    // pin - 46 bytes
    buf.order(ByteOrder.BIG_ENDIAN);
    buf.putLong(GB_UUID_MASK);
    buf.putLong(id);
    buf.putLong(UUID_NOTIFICATIONS.getMostSignificantBits());
    buf.putLong(UUID_NOTIFICATIONS.getLeastSignificantBits());
    buf.order(ByteOrder.LITTLE_ENDIAN);
    buf.putInt(timestamp); // 32-bit timestamp
    buf.putShort((short) 0); // duration
    buf.put((byte) 0x01); // type (0x01 = notification)
    buf.putShort((short) 0x0001); // flags 0x0001 = ?
    buf.put((byte) 0x04); // layout (0x04 = notification?)
    buf.putShort(attributes_length); // total length of all attributes and actions in bytes
    buf.put(attributes_count);
    buf.put(actions_count);
    
    byte attribute_id = 0;
    // Encode Pascal-Style Strings
    if (parts != null) {
        for (String s : parts) {
            attribute_id++;
            if (s == null || s.equals("")) {
                continue;
            }
            
            int partlength = s.getBytes().length;
            if (partlength > 512) partlength = 512;
            buf.put(attribute_id);
            buf.putShort((short) partlength);
            buf.put(s.getBytes(), 0, partlength);
        }
    }
    
    buf.put((byte) 4); // icon
    buf.putShort((short) 4); // length of int
    buf.putInt(0x80000000 | icon_id);
    
    buf.put((byte) 28); // background_color
    buf.putShort((short) 1); // length of int
    buf.put(color_id);
    
    // dismiss action
    buf.put(dismiss_action_id);
    buf.put((byte) 0x02); // generic action, dismiss did not do anything
    buf.put((byte) 0x01); // number attributes
    buf.put((byte) 0x01); // attribute id (title)
    buf.putShort((short) dismiss_string.getBytes().length);
    buf.put(dismiss_string.getBytes());
    
    // open and mute actions
    if (hasHandle && !"ALARMCLOCKRECEIVER".equals(sourceName)) {
        buf.put((byte) 0x01);
        buf.put((byte) 0x02); // generic action
        buf.put((byte) 0x01); // number attributes
        buf.put((byte) 0x01); // attribute id (title)
        buf.putShort((short) open_string.getBytes().length);
        buf.put(open_string.getBytes());
        
        buf.put((byte) 0x04);
        buf.put((byte) 0x02); // generic action
        buf.put((byte) 0x01); // number attributes
        buf.put((byte) 0x01); // attribute id (title)
        buf.putShort((short) mute_string.getBytes().length);
        buf.put(mute_string.getBytes());
    }
    
    if (cannedReplies != null && replies_length > 0) {
        buf.put((byte) 0x05);
        buf.put((byte) 0x03); // reply action
        buf.put((byte) 0x02); // number attributes
        buf.put((byte) 0x01); // title
        buf.putShort((short) reply_string.getBytes().length);
        buf.put(reply_string.getBytes());
        buf.put((byte) 0x08); // canned replies
        buf.putShort((short) replies_length);
        for (int i = 0; i < cannedReplies.length - 1; i++) {
            buf.put(cannedReplies[i].getBytes());
            buf.put((byte) 0x00);
        }
        // last one must not be zero terminated, else we get an additional emply reply
        buf.put(cannedReplies[cannedReplies.length - 1].getBytes());
    }
    
    return encodeBlobdb(UUID.randomUUID(), BLOBDB_INSERT, BLOBDB_NOTIFICATION, buf.array());
}
 */
