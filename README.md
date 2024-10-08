#  Push Notification

## Features for Push Notification
- [x] Enable/disable 
- [x] Increment app icon badge count   
* [feat: increment app icon badge count](https://github.com/CarlsonYuan/agora-chat-sample-ios/commit/fc0f52a2730d1451efe658121d0dcc8d8d1eff6d)
- [x] Media attachments
* [feat: push notifications with media attachment](https://github.com/CarlsonYuan/agora-chat-sample-ios/commit/ef38a712a37e36145a887188424923e5f2bfd049)
- [x] Sound
- [x] Translation
- [x] Change push notification content display
---

## Change Push Notification Content Display
### Push notification content display type

| AgoraChatPushDisplayStyle | Preview |
|----------|----------|
| AgoraChatPushDisplayStyle.simpleBanner | ![IMG_3369](https://github.com/CarlsonYuan/agora-chat-sample-ios/assets/123744402/2fb7fea9-54da-412b-a5cd-b4815c3252e5)|
| AgoraChatPushDisplayStyle.messageSummary |![IMG_3372 2](https://github.com/CarlsonYuan/agora-chat-sample-ios/assets/123744402/1ef5d27c-f3dc-4479-bc1f-704aabc0776e)|

To apply a display style to push notifications, use the method below. Specify the type of the display style with the name as either `AgoraChatPushDisplayStyle.simpleBanner` or `AgoraChatPushDisplayStyle.messageSummary`.

```swift
AgoraChatClient.shared().pushManager?.update(AgoraChatPushDisplayStyle.messageSummary, completion: { error in
    guard error == nil else {
        // Handle error.
        return
    }

    // AgoraChatPushDisplayStyle.messageSummary has been successfully set.
})
```

### Push template

The push notification content display can be customized at the application level using the [push template](https://docs.agora.io/en/agora-chat/develop/offline-push?platform=ios#set-up-push-templates) by specifying the template name as `default` , as shown below.
> Note: Once set to default, AgoraChatPushDisplayStyle will become unavailable.

| Template Setting  | Preview |
|----------|----------|
|  <img width="432" alt="image" src="https://github.com/CarlsonYuan/agora-chat-sample-ios/assets/123744402/5f9a7641-99f2-4b78-ba59-8a76b4632e25">   | ![Screenshot 2024-05-24 at 14 15 04](https://github.com/CarlsonYuan/agora-chat-sample-ios/assets/123744402/0d98b6ae-bea7-46d8-94e6-f183f3b8e809) |

---

## Push notification translation 
To enable push notification translation functionality, follow these steps:

1. **Enable Translation Service**: 
   - Translation is not enabled by default. To use this feature, you need to subscribe to the Pro or Enterprise pricing plan and enable it in Agora Console.

2. **Set Preferences**:
   - [Set user's preferred languages](https://docs.agora.io/en/agora-chat/develop/offline-push?platform=ios#set-up-push-translations)

3. **Add Target Languages**:
   - When sending messages from the client side that you want to be translated via push notifications, ensure that you [include target languages in your message settings](https://docs.agora.io/en/agora-chat/client-api/messages/translate-messages?platform=ios#automatic-translation).


## Sending notifications
### Via REST
```
curl -X POST \
-H 'Authorization: Bearer ${AppToken}' \
'https://${REST_API}/${OrgName}/${AppName}/messages?useMsgId=true' \
-d '{
    "from": "${senderUsername}",
    "target_type": "users",
    "target": [
        "${receiverUsername}",
        "${receiverUsername}"
    ],
    "msg": {
        "msg": "this is a test message",
        "type": "txt"
    },
    "ext": {
        "em_apns_ext": {                       // mapping "aps" (Apple-defined key)
            "em_push_mutable_content": true,   // mapping "mutable-content" (Apple-defined key)
            "em_push_sound": "sample-3s.wav",  // mapping "sound" (Apple-defined key)
            "extern": {                        // mapping "e" in the userInfo for remote notifications
                "media-url": "${url}"          // custom key-value
            }
        },
        "em_push_template": {
            "name": "${templateName}",
            "title_args": [
                "${arg1}"
            ],
            "content_args": [
                "${arg1}"
            ]
        }
    }
}'
```

To learn more about apple-defined keys, view the [Apple Documentation](https://developer.apple.com/documentation/usernotifications/generating-a-remote-notification#Payload-key-reference)  
To learn more about the REST API, view the [Agora Documentation](https://docs.agora.io/en/agora-chat/restful-api/message-management?platform=web#send-a-message)

### Via Chat SDKs

For example, when using the [AgoraChat_iOS](https://github.com/AgoraIO/AgoraChat_iOS) SDK to send messages:

```
let body = AgoraChatTextMessageBody.init(text: text)
body.targetLanguages = ["en", "ja"]
let message = AgoraChatMessage.init(conversationID: group.groupId, body: body, ext: nil)
message.chatType = .groupChat
var messageExt = [String: Any]()

// uncommit to set push template
//        let emPushTemplate: [String: Any] = [
//            "name": "tmp1",
//            "title_args": ["titleArg1"],
//            "content_args": ["contentArg1"]
//        ]
//        messageExt["em_push_template"] = emPushTemplate

// uncommit to set push rich media
//        messageExt["em_apns_ext"] = [
//            "em_push_mutable_content": true,
//            "extern": ["media-url": "https://github.com/CarlsonYuan.png"]
//        ]

message.ext = messageExt
AgoraChatClient.shared().chatManager?.send(message, progress: nil, completion: { message, error in })
```

See [Custom Fields](https://docs.agora.io/en/agora-chat/develop/offline-push?platform=ios#custom-fields) to learn about how to customize your push notifications. 

## Device token operations by the RESTful API 
* list the registered tokens 
```
curl -X GET \
-H 'Authorization: Bearer ${AppToken}' \
'https://${REST_API}/${OrgName}/${AppName}/users/${username}/push/binding'
```

* Unregister device token using this command: 
```
curl -X PUT \
-H 'Authorization: Bearer ${AppToken}' \
'https://${REST_API}/${OrgName}/${AppName}/users/${username}/push/binding' \
-d '{
    "device_id": "${deviceId}",
    "device_token": "",
    "notifier_name": "${apnsCertName}"
}'
```
