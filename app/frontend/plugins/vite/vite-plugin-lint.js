import { exec } from 'node:child_process'

// Runs the lint command at the start of the build and on subsequent updates
const lintPlugin = () => {
  const runLinting = async () => {
    await exec('npm run lint', (_, output, err) => {
      if (output) console.log(output)
      if (err) console.log(err)
    })
  }
  return {
    name: 'lint',
    buildStart: runLinting,
    handleHotUpdate: runLinting
  }
}

export default lintPlugin
