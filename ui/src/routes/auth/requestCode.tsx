import { useState, useContext } from 'react'

import { useNavigate } from 'react-router-dom'

import { styled } from '@mui/material/styles'
import Box from '@mui/material/Box'
import Grid from '@mui/material/Grid'
import Button from '@mui/material/Button'
import Typography from '@mui/material/Typography'
import Paper from '@mui/material/Paper'

import { useValidUsername } from '../../hooks/useAuthHooks'
import { Username } from '../../components/authComponents'

import { AuthContext } from '../../contexts/authContext'

const FullHeightRoot = styled(Grid)({
    height: '100vh',
});

const TypographyWithCenterText = styled(Typography)({
  textAlign: 'center'
});

export default function RequestCode() {

  const { username, setUsername, usernameIsValid } = useValidUsername('')
  const [error, setError] = useState('')
  const [resetSent, setResetSent] = useState(false)

  const isValid = !usernameIsValid || username.length === 0

  const navigate = useNavigate()

  const authContext = useContext(AuthContext)

  const sendCodeClicked = async () => {
    try {
      await authContext.sendCode(username)
      setResetSent(true)
    } catch (err) {
      setError('Unknown user')
    }
  }

  const emailSent = (
    <>
      <Box mt={1}>
        <TypographyWithCenterText variant="h5">{`Reset Code Sent to ${username}`}</TypographyWithCenterText>
      </Box>
      <Box mt={4}>
        <Button onClick={() => navigate('/forgotpassword')} color="primary" variant="contained">
          Reset Password
        </Button>
      </Box>
    </>
  )

  const sendCode = (
    <>
      <Box width="80%" m={1}>
        <Username usernameIsValid={usernameIsValid} setUsername={setUsername} />
      </Box>
      <Box mt={2}>
        <Typography color="error" variant="body2">
          {error}
        </Typography>
      </Box>

      <Box mt={2}>
        <Grid container direction="row" justifyContent="center">
          <Box m={1}>
            <Button color="secondary" variant="contained" onClick={() => navigate(-1)}>
              Cancel
            </Button>
          </Box>
          <Box m={1}>
            <Button disabled={isValid} color="primary" variant="contained" onClick={sendCodeClicked}>
              Send Code
            </Button>
          </Box>
        </Grid>
      </Box>
    </>
  )

  return (
    <FullHeightRoot container direction="row" justifyContent="center" alignItems="center">
      <Grid xs={11} sm={6} lg={4} container direction="row" justifyContent="center" alignItems="center" item>
        <Paper style={{ width: '100%', padding: 32 }}>
          <Grid container direction="column" justifyContent="center" alignItems="center">
            <Box m={2}>
              <Typography variant="h3">Send Reset Code</Typography>
            </Box>

            {resetSent ? emailSent : sendCode}
          </Grid>
        </Paper>
      </Grid>
    </FullHeightRoot>
  )
}