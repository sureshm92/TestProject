## RH-11.0_PP-9.0 Pre Deployment Steps:
### Note: Steps 1-3 are only meant for release manager, no AIQ steps needed. Not for sandbox.
#### Before production package creation follow the folling steps -
1. Open file path `force-app\communities\community-gsk\experiences\GSK_Community1.site-meta.xml` > Change `<urlPathPrefix>gsk/s</urlPathPrefix>` to `<urlPathPrefix>s</urlPathPrefix>`
2. Open file path `force-app\communities\community-janssen\experiences\Janssen_Community1.site-meta.xml` > Change `<urlPathPrefix>janssen/s</urlPathPrefix>` to `<urlPathPrefix>s</urlPathPrefix>`
3. Uncomment the following line in `.forceignore` file `#force-app/main/default/WalkMeCommunity*`

