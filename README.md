``` haskell
Prelude Network.HaskellNet.IMAP.SSL> cnx <- connectIMAPSSL "imap.gmail.com"
Prelude Network.HaskellNet.IMAP> login cnx "alex@gmail.com" "mypassword"
Prelude Network.HaskellNet.IMAP> [(_, nbUnSeen)] <- status cnx "Inbox" [UNSEEN]
Prelude Network.HaskellNet.IMAP> nbUnSeen
1
```
