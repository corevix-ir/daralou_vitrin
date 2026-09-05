export type DeviceStatus = "active" | "offline" | "maintenance" | (string & {});

export interface Device {
  id: number;
  name: string;
  location: string;
  section: string;
  mac_address: string;
  ip_address: string;
  status: DeviceStatus;
  last_seen: string;
  config: Record<string, unknown>;
  created_at: string;
}

/** The device's own kiosk login is created together with the device — one request, both rows. */
export interface CreateDeviceUserPayload {
  username: string;
  password: string;
  role: "device";
  name: string;
}

export interface CreateDevicePayload {
  user: CreateDeviceUserPayload;
  name: string;
  location: string;
  section?: string;
  /** Exactly 12 chars, no separators (e.g. `AABBCCDDEEFF`). */
  mac_address: string;
  ip_address?: string;
  config?: Record<string, unknown>;
}

export interface UpdateDevicePayload {
  name?: string;
  status?: DeviceStatus;
  location?: string;
  section?: string;
  ip_address?: string;
  config?: Record<string, unknown>;
}

export interface DeviceCommandPayload {
  type: string;
  payload: Record<string, unknown>;
}
