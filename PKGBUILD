# Maintainer: Nathaniel Maia <natemaia10@gmail.com>
# Contributor: Chrysostomus @forum.manjaro.org

pkgname=archlabs-pacli
pkgver=0.9.2
pkgrel=2
pkgdesc="An interactive pacman interface using fzf"
arch=(any)
url="https://github.com/ARCHLabs/pacli"
license=(GPL2)
depends=('fzf'
	'pacman'
	'archlabs-yaourt'
	'pacman-mirrorlist'
	'sudo'
	'gzip'
	'archlabs-downgrade'
	'bash')
makedepends=('git')
groups=('archlabs')
optdepends=('update-notifier: Automatically get notified when updates are available')
source=("git://github.com/ARCHLabs/pacli")
md5sums=('SKIP')
provides=('pacli')
conflicts=('pacli' 'pacli-simple')
validpgpkeys=('AEFB411B072836CD48FF0381AE252C284B5DBA5D'
              '9E4F11C6A072942A7B3FD3B0B81EB14A09A25EB0')

package () {
    cd "$srcdir/pacli"
    install -dm755 "${pkgdir}/usr/lib/pacli"
    install -dm755 "${pkgdir}/usr/share/doc/pacli"
    install -dm755 "${pkgdir}/etc/pacman.d/hooks"

    install -Dm755 "$srcdir/pacli/pacli" "$pkgdir/usr/bin/pacli"
    cp -r lib/* "$pkgdir/usr/lib/pacli"
    chmod +x "$pkgdir/usr/lib/pacli/pacli-description.sh"
    ln -s "$pkgdir/usr/lib/pacli/pacli-description.sh" "$pkgdir/etc/pacman.d/hooks/pacli-description.sh"

    install -Dm644 pacli.help "$pkgdir/usr/share/doc/pacli/help"
    for lg in {fr,fr}; do   #for lg in {fr,de,it,sp}; do
        install -Dm644 "pacli.$lg.help" "$pkgdir/usr/share/doc/pacli/$lg.help"
    done
    mkdir -p $pkgdir/usr/share/locale/{de,fr,pl}/LC_MESSAGES/
    for lg in {fr,fr}; do   #for lg in {fr,de,it,pl,sp}; do
        msgfmt "locale/$lg.po" -o "$pkgdir/usr/share/locale/$lg/LC_MESSAGES/pacli.mo"
    done
}
