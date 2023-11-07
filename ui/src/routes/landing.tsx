import React from 'react'

import { useNavigate } from 'react-router-dom'

import { styled } from '@mui/material/styles'

import Typography from '@mui/material/Typography'
import Grid from '@mui/material/Grid'
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
import Link from '@mui/material/Link'
import GitHubIcon from '@mui/icons-material/GitHub'

import logoImage from './logo.png'


const FullHeightRoot = styled(Grid)({
    height: '100vh',
});

const Title = styled(Typography)({
    textAlign: 'center',
  });


const Landing: React.FunctionComponent = () => {

  const navigate = useNavigate()

  const signIn = () => {
    navigate('/signin')
  }

  return (
    <Grid container>
      <FullHeightRoot container direction="column" justifyContent="center" alignItems="center">
        <Box m={2}>
          <img src={logoImage} width={224} height={224} alt="logo" />
        </Box>
        <Box m={2}>
          <Link underline="none" color="inherit" href="https://github.com/dbroadhurst/aws-cognito-react">
            <Grid container direction="row" justifyContent="center" alignItems="center">
              <Box mr={3}>
                <GitHubIcon fontSize="large" />
              </Box>
              <Title variant="h3">
                AWS Cognito Starter
              </Title>
            </Grid>
          </Link>
        </Box>
        <Box m={2}>
          <Button onClick={signIn} variant="contained" color="primary">
            SIGN IN
          </Button>
        </Box>
      </FullHeightRoot>
    </Grid>
  )
}

export default Landing