import React from 'react'
import './App.css'

import { HashRouter as Router, Route, Routes } from 'react-router-dom'

import { createTheme, ThemeProvider, responsiveFontSizes } from '@mui/material/styles'
import CssBaseline from '@mui/material/CssBaseline'

import AuthProvider, { AuthIsSignedIn, AuthIsNotSignedIn } from './contexts/authContext'

import SignIn from './routes/auth/signIn'
import SignUp from './routes/auth/signUp'
import VerifyCode from './routes/auth/verify'
import RequestCode from './routes/auth/requestCode'
import ForgotPassword from './routes/auth/forgotPassword'
import ChangePassword from './routes/auth/changePassword'
import Landing from './routes/landing'
import Home from './routes/home'

let lightTheme = createTheme({
  palette: {
    mode: 'light',
  },
})
lightTheme = responsiveFontSizes(lightTheme)

// let darkTheme = createTheme({
//   palette: {
//     mode: 'dark',
//   },
// })
// darkTheme = responsiveFontSizes(darkTheme)

const SignInRoute: React.FunctionComponent = () => (
  <Router>
    <Routes>
      <Route path="/signin" element={<SignIn />} />
      <Route path="/signup" element={<SignUp />} />
      <Route path="/verify" element={<VerifyCode />} />
      <Route path="/requestcode" element={<RequestCode />} />
      <Route path="/forgotpassword" element={<ForgotPassword />} />
      <Route path="/" element={<Landing />} />
    </Routes>
  </Router>
)

const MainRoute: React.FunctionComponent = () => (
  <Router>
    <Routes>
      <Route path="/changepassword" element={<ChangePassword />} />
      <Route path="/" element={<Home />} />
    </Routes>
  </Router>
)

const App: React.FunctionComponent = () => (
  <ThemeProvider theme={lightTheme}>
    <CssBaseline />
    <AuthProvider>
      <AuthIsSignedIn>
        <MainRoute />
      </AuthIsSignedIn>
      <AuthIsNotSignedIn>
        <SignInRoute />
      </AuthIsNotSignedIn>
    </AuthProvider>
  </ThemeProvider>
)

export default App
