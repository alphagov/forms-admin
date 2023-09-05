const replaceBulletCharacters = markdown => {
  return markdown.replaceAll(/[^\S\r\n]*•\s*/g, '* ')
}

export default replaceBulletCharacters
