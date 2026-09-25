// Extracts a "lat,lng" pair out of a pasted Google Maps or Waze link.
// Short links (goo.gl/maps, maps.app.goo.gl, waze.com/ul/<id>) can't be
// resolved client-side since following the redirect needs a real request,
// which the browser blocks cross-origin — those are left untouched so the
// user can paste the coordinates manually instead.
const COORDINATE_PATTERNS = [
  /@(-?\d{1,2}\.\d+),(-?\d{1,3}\.\d+)/, // Google Maps: .../@18.4861,-69.9312,15z
  /[?&](?:q|query)=(-?\d{1,2}\.\d+),(-?\d{1,3}\.\d+)/, // Google Maps: ?q=18.4861,-69.9312
  /[?&]ll=(-?\d{1,2}\.\d+),(-?\d{1,3}\.\d+)/, // Google Maps / Waze: ?ll=18.4861,-69.9312
  /to=ll\.(-?\d{1,2}\.\d+),(-?\d{1,3}\.\d+)/, // Waze: ?to=ll.18.4861,-69.9312
];

const RAW_COORDINATES_PATTERN =
  /^\s*(-?\d{1,2}\.\d+)\s*,\s*(-?\d{1,3}\.\d+)\s*$/;

const isValidLatLng = (lat, lng) => Math.abs(lat) <= 90 && Math.abs(lng) <= 180;

/**
 * @param {string} value - A pasted Google Maps/Waze URL, or raw "lat,lng" text.
 * @returns {string|null} Normalized "lat,lng" string, or null if nothing could be parsed.
 */
export const extractCoordinates = value => {
  if (!value) return null;

  let decoded = value;
  try {
    decoded = decodeURIComponent(value);
  } catch {
    // Not URL-encoded, use the raw value as-is.
  }

  const rawMatch = decoded.match(RAW_COORDINATES_PATTERN);
  if (rawMatch) {
    const [, lat, lng] = rawMatch;
    if (isValidLatLng(Number(lat), Number(lng))) return `${lat},${lng}`;
  }

  const matchedPair = COORDINATE_PATTERNS.map(pattern =>
    decoded.match(pattern)
  ).find(match => match && isValidLatLng(Number(match[1]), Number(match[2])));

  return matchedPair ? `${matchedPair[1]},${matchedPair[2]}` : null;
};

const MAPS_HOSTS = [
  'google.com',
  'www.google.com',
  'maps.google.com',
  'goo.gl',
  'maps.app.goo.gl',
  'waze.com',
  'www.waze.com',
];

const isMapsLink = value => {
  try {
    const { protocol, hostname } = new URL(value);
    return protocol === 'https:' && MAPS_HOSTS.includes(hostname);
  } catch {
    return false;
  }
};

/**
 * Builds the link shown for a contact's stored location. The location can be
 * set from the widget SDK, so anything that isn't coordinates or a known
 * Google Maps/Waze link is ignored instead of being rendered as a link.
 * @param {string} value - Stored "lat,lng" coordinates or a Maps/Waze URL.
 * @returns {string} Link to open, or '' if the value isn't a usable location.
 */
export const buildMapsUrl = value => {
  const coordinates = extractCoordinates(value);
  if (coordinates) return `https://www.google.com/maps?q=${coordinates}`;
  return isMapsLink(value) ? value : '';
};
