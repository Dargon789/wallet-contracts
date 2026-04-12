
  import { SequenceConnect, createConfig } from '@0xsequence/connect'

  export function App() {
    const projectAccessKey = "AQAAAAAAAJbd_5JOcE50AqglZCtvu51YlGI"
    const waasConfigKey = "eyJwcm9qZWN0SWQiOjM4NjIxLCJycGNTZXJ2ZXIiOiJodHRwczovL3dhYXMuc2VxdWVuY2UuYXBwIn0=" // Pass in your waasConfigKey
    const enableConfirmationModal = true // change to your preference
    const googleClientId = 'YOUR_GOOGLE_CLIENT_ID' // Google Client ID
    const appleClientId = 'YOUR_APPLE_CLIENT_ID' // Apple Client ID
    const appleRedirectURI = 'YOUR_APP_SCHEME://auth' // Apple Redirect URI
    const walletConnectProjectId = 'walletConnectProjectId' // Pass in your WalletConnect Project ID

    const config = createConfig('waas', {
      projectAccessKey,
      position: "center",
      defaultTheme: "dark",
      signIn: {
        projectName: "sequence.app",
      },
      defaultChainId: 421614,
      chainIds: [1, 10, 40, 41, 56, 97, 100, 137, 143, 1101, 1284, 1287, 1868, 1946, 1993, 5031, 6252, 8333, 8453, 10143, 19011, 24101, 28802, 33111, 33139, 40875, 42161, 42170, 42793, 43113, 43114, 50312, 80002, 81457, 84532, 127823, 128123, 421614, 660279, 747474, 5042002, 11155111, 11155420, 21000000, 37084624, 168587773, 1482601649, 37714555429],
      appName: "sequence.app",
      email: true,
      waasConfigKey,
      google: {
        clientId: googleClientId
      },
      apple: {
        clientId: appleClientId,
        redirectURI: appleRedirectURI
      },
      walletConnect: {
        projectId: walletConnectProjectId
      },
      coinbase: true,
      metaMask: true,
      wagmiConfig: {
        multiInjectedProviderDiscovery: true,
      },
      enableConfirmationModal
    })

    return (
      <SequenceConnect config={config}>
        <MyPage />
      </SequenceConnect>
    );
}
