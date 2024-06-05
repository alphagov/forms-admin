/**
 * @vitest-environment jsdom
 */

import replaceBulletCharacters from './replace-bullet-characters'

it('converts bullet characters to markdown bullets', () => {
  expect(replaceBulletCharacters('•')).toEqual('* ')
})

it('converts bullet characters with appended whitespace to markdown bullets', () => {
  expect(replaceBulletCharacters('• ')).toEqual('* ')
})
