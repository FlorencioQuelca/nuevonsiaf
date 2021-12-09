import axios from 'axios'

class Api {
  constructor () {
    const baseURL = document.querySelector('meta[name="url"]')
                            .getAttribute('content')
    this.api = axios.create({
      baseURL: baseURL,
      withCredentials: false,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      }
    })
  }
}

export { Api as default }
